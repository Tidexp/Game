extends BaseCharacter

@export var speed: float = 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapons: Node2D = $Weapons

var idle_time_counter: float = 0.0
const IDLE_TIMEOUT: float = 0.5 
var attack_animation_timer: float = 0.0
var jump_animation_timer: float = 0.0
var jump_key_down: bool = false

signal exp_changed(current_exp: int, max_exp: int)
signal player_leveled_up(current_level: int)
signal weapons_changed

var current_exp: int = 0
var max_exp: int = 50
var level: int = 1

func _ready() -> void:
	super._ready() # Khởi tạo máu và bộ đếm i-frame từ BaseCharacter
	add_to_group("player")
	_apply_selected_character_texture()
	if animated_sprite:
		animated_sprite.play("default")
	weapons_changed.emit()

func _apply_selected_character_texture() -> void:
	if not animated_sprite:
		return
	var character: Dictionary = GameData.CHARACTERS.get(GameData.selected_character_id, {})
	if character.is_empty():
		return
	var normal_path: String = character.get("normal_path", character.get("sprite_path", ""))
	var animation_paths := {
		"default": normal_path,
		"run": character.get("run_path", normal_path),
		"lobby": normal_path,
		"attack": character.get("attack_path", ""),
		"jump": character.get("jump_path", "")
	}
	var frames := animated_sprite.sprite_frames.duplicate() as SpriteFrames
	animated_sprite.sprite_frames = frames
	for animation_name in animation_paths:
		var texture_path: String = animation_paths[animation_name]
		if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
			continue
		var texture := load(texture_path) as Texture2D
		if not texture:
			continue
		if not frames.has_animation(animation_name):
			frames.add_animation(animation_name)
		frames.clear(animation_name)
		frames.add_frame(animation_name, texture)
		frames.set_animation_speed(animation_name, 8.0)
		frames.set_animation_loop(animation_name, not ["attack", "jump"].has(animation_name))

func play_attack_animation() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames.has_animation("attack"):
		return
	attack_animation_timer = 0.25
	jump_animation_timer = 0.0
	idle_time_counter = IDLE_TIMEOUT
	animated_sprite.play("attack")

func play_jump_animation() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames.has_animation("jump"):
		return
	jump_animation_timer = 0.4
	attack_animation_timer = 0.0
	idle_time_counter = IDLE_TIMEOUT
	animated_sprite.play("jump")

func add_exp(amount: int) -> void:
	current_exp += amount
	emit_signal("exp_changed", current_exp, max_exp)
	if current_exp >= max_exp:
		level_up()

func level_up() -> void:
	level += 1
	current_exp -= max_exp
	max_exp = int(max_exp * 1.5)
	emit_signal("exp_changed", current_exp, max_exp)
	player_leveled_up.emit(level)

func apply_upgrade(data: Dictionary) -> void:
	match data["type"]:
		"new_weapon":
			var weapon_scene: PackedScene = data["scene"]
			var new_weapon = weapon_scene.instantiate()
			# Đặt tên node trùng ID ("Sugarcane", "Shisa", "Shield") để chống lỗi trùng lặp
			new_weapon.name = data["id"]
			weapons.add_child(new_weapon)
		"upgrade_weapon":
			var weapon_id: String = data["id"]
			var weapon = weapons.get_node_or_null(weapon_id)
			if weapon:
				if weapon.has_method("upgrade"):
					weapon.upgrade()
				elif weapon.has_method("level_up"):
					weapon.level_up()
		"stat":
			if data["id"] == "heal":
				health = clamp(health + 30, 0, max_health)
				if has_method("update_health_ui"):
					update_health_ui()
			elif data["id"] == "speed":
				speed *= 1.15
	weapons_changed.emit()

# --- HÀM NHẬN SÁT THƯƠNG (TÍNH GIẢM SÁT THƯƠNG TỪ KHIÊN + DÙNG I-FRAME GỐC) ---
func take_damage(amount: int) -> void:
	var final_damage: float = float(amount)
	
	# Tính giảm sát thương nếu sở hữu Khiên
	var shield_node = weapons.get_node_or_null("Shield")
	if shield_node and shield_node.has_method("get_damage_reduction"):
		var reduction: float = shield_node.get_damage_reduction()
		final_damage -= final_damage * reduction

	var actual_damage: int = max(1, int(round(final_damage)))
	
	# Giao cho BaseCharacter xử lý trừ máu và kích hoạt i-frame
	super.take_damage(actual_damage)

func _physics_process(delta: float) -> void:
	super._physics_process(delta) # Giữ bộ đếm thời gian i-frame của BaseCharacter chạy
	var jump_pressed := Input.is_key_pressed(KEY_SPACE)
	if jump_pressed and not jump_key_down:
		play_jump_animation()
	jump_key_down = jump_pressed
	attack_animation_timer = maxf(0.0, attack_animation_timer - delta)
	jump_animation_timer = maxf(0.0, jump_animation_timer - delta)
	
	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1
		
	direction = direction.normalized()
	
	if jump_animation_timer > 0.0:
		pass
	elif attack_animation_timer > 0.0:
		if animated_sprite and animated_sprite.animation != "attack":
			animated_sprite.play("attack")
	elif direction != Vector2.ZERO:
		idle_time_counter = 0.0
		velocity = direction * speed
		if animated_sprite:
			animated_sprite.play("run")
			if direction.x != 0:
				animated_sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		idle_time_counter += delta
		if idle_time_counter >= IDLE_TIMEOUT and animated_sprite:
			animated_sprite.play("default")
		
	move_and_slide()
