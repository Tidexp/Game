# phone.gd
extends Node2D

var level: int = 1
const MAX_LEVEL: int = 5

@export var fear_duration: float = 2.5
@export var fear_radius: float = 220.0 # Bán kính sóng âm phát ra

@onready var ring_timer: Timer = $RingTimer

const UPGRADE_DESCRIPTIONS = {
	2: "Tăng 1 giây thời gian hoảng sợ",
	3: "Mở rộng vùng ảnh hưởng sóng điện thoại",
	4: "Giảm thời gian hồi chiêu đổ chuông",
	5: "Gây hoảng sợ cực đại (4 giây)"
}

func _ready() -> void:
	ring_timer.timeout.connect(_on_ring_timer_timeout)
	# Kích hoạt hoảng sợ tức thì ngay khi vừa tạo node
	trigger_fear()

func _on_ring_timer_timeout() -> void:
	trigger_fear()

func trigger_fear() -> void:
	# Hiệu ứng nảy nhẹ khi phát chuông
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)

	# Quét trực tiếp danh sách quái trong group "enemies" mà không cần đợi physics frame
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("apply_fear"):
			if global_position.distance_to(enemy.global_position) <= fear_radius:
				enemy.apply_fear(fear_duration, global_position)

func level_up() -> void:
	if level < MAX_LEVEL:
		level += 1
		match level:
			2:
				fear_duration = 3.5
			3:
				fear_radius *= 1.3
			4:
				ring_timer.wait_time = max(1.5, ring_timer.wait_time - 1.0)
			5:
				fear_duration = 4.5
		
		# Nâng cấp level cũng nổ chuông ngay lập tức
		trigger_fear()
