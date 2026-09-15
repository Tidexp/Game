extends Control

@onready var progress_bar: ProgressBar = $%LoadingBar
@onready var play_button: TextureButton = $%PlayButton
@onready var settings_button: TextureButton = $%SettingsButton
@onready var quit_button: TextureButton = $%QuitButton

func _ready() -> void:
	# Kết nối tín hiệu sự kiện nút bấm
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Khóa nút Play và chạy thanh Loading giả lập khi khởi động
	play_button.disabled = true
	if progress_bar:
		progress_bar.value = 0
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", 100, 1.5)
		tween.finished.connect(_on_loading_complete)

func _on_loading_complete() -> void:
	play_button.disabled = false
	if progress_bar:
		progress_bar.hide() # Ẩn thanh loading sau khi tải xong

func _on_play_pressed() -> void:
	# Chuyển hướng sang scene game chính của bạn
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")

func _on_settings_pressed() -> void:
	print("Mở giao diện cài đặt âm thanh/đồ họa...")

func _on_quit_pressed() -> void:
	get_tree().quit()
