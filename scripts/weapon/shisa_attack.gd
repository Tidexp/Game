extends Area2D

var damage: int = 10
var tick_rate: float = 0.2
var tick_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	stop_attack()

func start_attack(new_damage: int, target_scale: float = 1.0) -> void:
	damage = new_damage
	tick_timer = 0.0
	visible = true
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	
	# Gây sát thương ngay lập tức cho toàn bộ đám quái đang đứng trong vùng
	deal_aoe_damage()
	
	scale = Vector2(0.3, 0.3) * target_scale
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.12)

func stop_attack() -> void:
	visible = false
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	if not visible:
		return
		
	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		deal_aoe_damage()

# Quét và đánh trúng toàn bộ quái vật không sót con nào
func deal_aoe_damage() -> void:
	var hit_targets: Array = []

	# 1. Quét các Body (CharacterBody2D / RigidBody2D)
	for body in get_overlapping_bodies():
		var target = _find_enemy_root(body)
		if target and not hit_targets.has(target):
			hit_targets.append(target)

	# 2. Quét các Area2D (nếu quái làm bằng Hurtbox Area2D)
	for area in get_overlapping_areas():
		var target = _find_enemy_root(area)
		if target and not hit_targets.has(target):
			hit_targets.append(target)

	# 3. Trừ máu đồng loạt trên từng thực thể kẻ địch
	for enemy in hit_targets:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

# Hàm tìm đúng node gốc của quái vật để tránh trừ máu 2 lần trên 1 con
func _find_enemy_root(node: Node) -> Node:
	if node.is_in_group("enemies"):
		return node
	if node.get_parent() and node.get_parent().is_in_group("enemies"):
		return node.get_parent()
	return null
