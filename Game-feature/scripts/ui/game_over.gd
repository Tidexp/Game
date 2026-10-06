extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.02, 0.025, 0.78)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 240)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.075, 0.07, 0.98)
	panel_style.border_color = Color(0.78, 0.22, 0.16)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 28
	panel_style.content_margin_top = 24
	panel_style.content_margin_right = 28
	panel_style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.95, 0.25, 0.2))
	content.add_child(title)

	var message := Label.new()
	message.text = "Bạn đã bị hạ gục"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 18)
	message.add_theme_color_override("font_color", Color(0.9, 0.87, 0.82))
	content.add_child(message)

	var replay_button := Button.new()
	replay_button.text = "Chơi lại"
	replay_button.custom_minimum_size.y = 42
	replay_button.pressed.connect(_on_replay_pressed)
	content.add_child(replay_button)

	var home_button := Button.new()
	home_button.text = "Màn hình chính"
	home_button.custom_minimum_size.y = 42
	home_button.pressed.connect(_on_home_pressed)
	content.add_child(home_button)

func _on_replay_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")