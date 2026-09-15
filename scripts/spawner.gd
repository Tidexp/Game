extends Node2D

# Tải trước scene của quái
var enemy_scene = preload("res://scenes/enemies/enemy.tscn")
@onready var timer = $Timer

# Số lượng quái xuất hiện trong mỗi đợt bầy đàn
@export var batch_size: int = 5

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Vòng lặp sinh ra một bầy quái quanh người chơi
	for i in range(batch_size):
		# Tạo khoảng cách ngẫu nhiên ngoài tầm nhìn (từ 500 đến 700 pixel)
		var spawn_distance = randf_range(500.0, 700.0)
		# Tạo góc quay ngẫu nhiên từ 0 đến 360 độ (2 * PI)
		var spawn_angle = randf() * PI * 2
		
		# Tính tọa độ xuất hiện dựa theo vị trí hiện tại của player
		var spawn_offset = Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
		var spawn_position = player.global_position + spawn_offset

		# Khởi tạo đối tượng quái mới
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_position
		
		# Đưa quái vào scene hiện tại để nó bắt đầu đuổi theo player
		get_tree().current_scene.add_child(enemy)
