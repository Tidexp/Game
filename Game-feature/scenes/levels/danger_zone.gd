extends Area2D

@onready var alert_sound: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("--- Đã phát hiện va chạm với: ", body.name)
	print("Thuộc các Groups: ", body.get_groups())
	
	# Bỏ qua Player
	if body.name == "Player" or body.is_in_group("Player"):
		print("--> Đây là Player, bỏ qua.")
		return
		
	# In ra để xem con quái đang mang tên hoặc group gì
	print("--> Đây là đối tượng khác, tiến hành phát âm thanh cảnh báo!")
	
	if alert_sound and alert_sound.stream:
		if not alert_sound.playing:
			alert_sound.play()
	else:
		print("Lỗi: AudioStreamPlayer chưa có file âm thanh hoặc chưa được gán đúng!")
