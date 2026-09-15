extends BaseCharacter

@export var speed: float = 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapons: Node2D = $Weapons

var idle_time_counter: float = 0.0
const IDLE_TIMEOUT: float = 0.5 

signal exp_changed(current_exp: int, max_exp: int)
signal player_leveled_up(current_level: int)

var current_exp: int = 0
var max_exp: int = 50
var level: int = 1

func _ready() -> void:
	super._ready() # Khởi tạo máu và bộ đếm i-frame từ BaseCharacter
	add_to_group("player")
	if animated_sprite:
		animated_sprite.play("default")

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
	
	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1
		
	direction = direction.normalized()
	
	if direction != Vector2.ZERO:
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
