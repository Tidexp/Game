extends CharacterBody2D

@export var speed: float = 120.0
@export var damage: int = 10

# --- THÔNG SỐ MÁU ---
@export var max_health: int = 40
var health: int = 40

# Quái rơi EXP khi chết
var exp_gem_scene: PackedScene = preload("res://scenes/objects/exp_gem.tscn")

var player: Node2D = null
var is_dead: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	# Đảm bảo quái luôn thuộc nhóm "enemies" khi xuất hiện
	add_to_group("enemies")
	health = max_health
	
	# Tìm tham chiếu đến người chơi
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if player:
		# Tính hướng di chuyển bám theo người chơi
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		# Lật hướng mặt nhìn theo người chơi
		if direction.x != 0 and sprite:
			sprite.flip_h = direction.x < 0

	# Gây sát thương khi húc trúng người chơi
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)

# --- NHẬN SÁT THƯƠNG (XỬ LÝ DỨT ĐIỂM SÁT THƯƠNG ĐA MỤC TIÊU) ---
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	health -= amount
	health = clamp(health, 0, max_health)
	
	# Hiệu ứng chớp đỏ báo hiệu dính đòn (không dùng iframe để nhận đủ sát thương DOT)
	modulate = Color(2.0, 0.4, 0.4)
	var flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	
	if health <= 0:
		is_dead = true
		
		# 1. Gỡ khỏi nhóm ngay lập tức để vũ khí (Shisa/Sugarcane) chuyển mục tiêu sang con khác
		remove_from_group("enemies")
		
		# 2. Tắt va chạm vật lý để không chắn đạn hay cản đường các con quái phía sau
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
			
		die()

func die() -> void:
	# Rơi ngọc kinh nghiệm
	if exp_gem_scene:
		var exp_gem = exp_gem_scene.instantiate()
		exp_gem.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_gem)
	
	queue_free()
