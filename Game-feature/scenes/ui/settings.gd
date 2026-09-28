extends Control

@onready var master_slider: HSlider = $MasterSlider
@onready var btn_back: Button = $BtnBack

func _ready() -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	
	if master_slider:
		master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_idx))
		master_slider.value_changed.connect(func(value: float):
			AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
		)
	
	if btn_back:
		btn_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	# Quay trở lại màn chơi game (đổi lại đường dẫn file map cho đúng với dự án của Kẻ mạnh)
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")
