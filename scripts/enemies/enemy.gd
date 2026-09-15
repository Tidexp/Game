extends CharacterBody2D

@export var speed: float = 120.0
@export var damage: int = 10

# --- THÔNG SỐ MÁU ---
@export var max_health: int = 40
var health: int = 40

# --- TRẠNG THÁI HOẢNG SỢ (HIỆU ỨNG TỪ ĐIỆN THOẠI) ---
var is_fearing: bool = false
var fear_timer: float = 0.0
var fear_source_pos: Vector2 = Vector2.ZERO

# Quái rơi EXP khi chết
var exp_gem_scene: PackedScene = preload("res://scenes/objects/exp_gem.tscn")

var player: Node2D = null
var is_dead: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	player = get_tree().get_first_node_in_group("player")

# --- HÀM KÍCH HOẠT TRẠNG THÁI HOẢNG SỢ ---
func apply_fear(duration: float, source_pos: Vector2) -> void:
	if is_dead:
		return
		
	# In debug ra output ngay khi dính trạng thái
	if not is_fearing:
		print("[FEAR TRIGGERED] %s hoảng loạn bỏ chạy ngay lập tức! (Thời gian: %.1fs)" % [name, duration])
		
	is_fearing = true
	fear_timer = duration
	fear_source_pos = source_pos
	
	modulate = Color(0.6, 0.8, 1.2)
	
	# Ép đổi vận tốc và quay mặt chạy trốn tức thì, không chờ _physics_process
	if player:
		var flee_direction = (global_position - player.global_position).normalized()
		velocity = flee_direction * (speed * 1.3)
		if flee_direction.x != 0 and sprite:
			sprite.flip_h = flee_direction.x < 0

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Đếm ngược thời gian hoảng sợ
	if is_fearing:
		fear_timer -= delta
		if fear_timer <= 0.0:
			is_fearing = false
			modulate = Color.WHITE
			print("[FEAR ENDED] %s hết sợ hãi, quay lại săn Player!" % name)

	# Xử lý di chuyển
	if player:
		var direction: Vector2 = Vector2.ZERO
		
		if is_fearing:
			# Chạy xa khỏi Player
			direction = (global_position - player.global_position).normalized()
			velocity = direction * (speed * 1.3)
		else:
			# Bám đuổi người chơi
			direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			
		move_and_slide()
		
		# Lật mặt theo hướng chạy thực tế
		if direction.x != 0 and sprite:
			sprite.flip_h = direction.x < 0

	# Chỉ gây sát thương khi KHÔNG bị sợ
	if not is_fearing:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider and collider.is_in_group("player"):
				if collider.has_method("take_damage"):
					collider.take_damage(damage)

# --- NHẬN SÁT THƯƠNG ---
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	health -= amount
	health = clamp(health, 0, max_health)
	
	modulate = Color(2.0, 0.4, 0.4)
	var flash_tween = create_tween()
	var return_color = Color(0.6, 0.8, 1.2) if is_fearing else Color.WHITE
	flash_tween.tween_property(self, "modulate", return_color, 0.08)
	
	if health <= 0:
		is_dead = true
		remove_from_group("enemies")
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		die()

func die() -> void:
	if exp_gem_scene:
		var exp_gem = exp_gem_scene.instantiate()
		exp_gem.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_gem)
	
	queue_free()
