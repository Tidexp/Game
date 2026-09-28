extends CanvasLayer

@onready var btn_replay: Button = $UIContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainerButtons/BtnReplay
@onready var btn_home: Button = $UIContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainerButtons/BtnHome
@onready var btn_settings: Button = $UIContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainerButtons/BtnSettings

# Khai báo đường dẫn đến node phát âm thanh
@onready var audio_player: AudioStreamPlayer = $UIContainer/PanelContainer/MarginContainer/VBoxContainer/AudioStreamPlayer

func _ready() -> void:
	# Kết nối sự kiện bấm nút
	btn_replay.pressed.connect(_on_replay_pressed)
	btn_home.pressed.connect(_on_home_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	
	# Tự động phát âm thanh chiến thắng ngay khi bảng Win hiện lên
	if audio_player:
		audio_player.play()

func _on_replay_pressed() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene() # Reset lại map chơi lại từ đầu

func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn") # Quay về màn hình chính (đổi lại đường dẫn nếu cần)

func _on_settings_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn") # Chuyển sang màn hình cài đặt âm lượng tổng riêng biệt
