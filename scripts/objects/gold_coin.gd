extends Area2D

@export var gold_amount: int = 5
@export var magnet_speed: float = 350.0
@export var magnet_radius: float = 150.0

var player: Node2D
var is_magnetized: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)

	var texture_path := "res://assets/sprites/coin/gold_coin.png"
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
	else:
		sprite.hide()
		queue_redraw()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	if global_position.distance_to(player.global_position) < magnet_radius:
		is_magnetized = true
	if is_magnetized:
		global_position = global_position.move_toward(player.global_position, magnet_speed * delta)

func _draw() -> void:
	if sprite and sprite.visible:
		return
	draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.78, 0.05))
	draw_arc(Vector2.ZERO, 8.0, 0.0, TAU, 24, Color(0.82, 0.48, 0.02), 2.0)
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 0.28))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameData.add_gold(gold_amount)
		queue_free()
