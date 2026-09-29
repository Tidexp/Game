extends Area2D

@export var exp_amount: int = 10
var player = null
var is_magnetized: bool = false
@export var magnet_speed: float = 350.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	if player:
		# Hiệu ứng hút khi player đến gần (Bán kính 150 pixel)
		var distance = global_position.distance_to(player.global_position)
		if distance < 150.0:
			is_magnetized = true
		
		if is_magnetized:
			var direction = global_position.direction_to(player.global_position)
			global_position += direction * magnet_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("add_exp"):
			body.add_exp(exp_amount)
		queue_free() # Nhặt xong thì xóa viên ngọc
