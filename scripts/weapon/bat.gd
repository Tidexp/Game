extends Area2D

@export var damage: int = 25
@export var level: int = 1
const MAX_LEVEL: int = 5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Biến tham chiếu đến nhân vật để lấy vị trí và hướng nhìn
var player: Node2D = null

# Các mốc mô tả nâng cấp
const UPGRADE_DESCRIPTIONS = {
	2: "Tăng +10 sát thương cho chày",
	3: "Tăng phạm vi vùng đập",
	4: "Tăng tốc độ vung chày",
	5: "Chày hoàng kim: Sát thương cực đại!"
}

func _ready() -> void:
	# Tắt va chạm lúc đầu, chỉ bật khi vung trúng đòn
	collision_shape.disabled = true
	
	# Tìm nhân vật trong nhóm "player"
	await get_tree().process_frame
	if get_tree().has_group("player"):
		player = get_tree().get_first_node_in_group("player")
	
	# Tự động vung chày định kỳ (ví dụ mỗi 1.2 giây)
	var timer = Timer.new()
	timer.wait_time = 1.2
	timer.autostart = true
	timer.timeout.connect(_on_attack_cooldown)
	add_child(timer)

func _process(delta: float) -> void:
	if player:
		# 1. Bám theo vị trí của nhân vật
		global_position = player.global_position
		
		# 2. Xử lý lật hướng và dịch chuyển chày sang tay trái/phải nhân vật
		if "last_direction" in player and player.last_direction != 0:
			var dir = sign(player.last_direction)
			scale.x = abs(scale.x) * dir
			position.x = 15 * dir # Thay đổi số 15 nếu muốn khoảng cách xa/gần tay hơn
		elif "velocity" in player and player.velocity.x != 0:
			var dir = sign(player.velocity.x)
			scale.x = abs(scale.x) * dir
			position.x = 15 * dir

func _on_attack_cooldown() -> void:
	if animation_player:
		animation_player.play("swing")

# Các hàm gọi trực tiếp từ AnimationPlayer bằng "Call Method Track"
func enable_hitbox() -> void:
	collision_shape.disabled = false

func disable_hitbox() -> void:
	collision_shape.disabled = true

func _on_body_entered(body: Node2D) -> void:
	print("Chày đã va chạm với: ", body.name) # In ra bảng Output để test hitbox
	
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		print("Đã gây ", damage, " sát thương lên quái: ", body.name)
