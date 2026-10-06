extends Control

@onready var progress_bar: ProgressBar = $%LoadingBar
@onready var play_button: TextureButton = $%PlayButton
@onready var settings_button: TextureButton = $%SettingsButton
@onready var quit_button: TextureButton = $%QuitButton
@onready var history_button: Button = $CanvasLayer/HistoryButton
@onready var history_canvas: CanvasLayer = $CanvasLayer
var history_overlay: ColorRect
var history_list: VBoxContainer

func _ready() -> void:
	# Kết nối tín hiệu sự kiện nút bấm
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	history_button.pressed.connect(_show_history)
	_build_history_ui()
	
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
	get_tree().change_scene_to_file("res://scenes/levels/character_lobby.tscn")

func _on_settings_pressed() -> void:
	print("Mở giao diện cài đặt âm thanh/đồ họa...")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _build_history_ui() -> void:
	history_overlay = ColorRect.new()
	history_overlay.color = Color(0.015, 0.02, 0.025, 0.82)
	history_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	history_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	history_overlay.hide()
	history_canvas.add_child(history_overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(640, 440)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.size = Vector2(640, 440)
	panel.position = Vector2(-320, -220)
	history_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)

	var header := HBoxContainer.new()
	content.add_child(header)

	var title := Label.new()
	title.text = "LỊCH SỬ MÀN ĐÃ HOÀN THÀNH"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "Đóng"
	close_button.pressed.connect(_close_history)
	header.add_child(close_button)

	var separator := HSeparator.new()
	content.add_child(separator)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	history_list = VBoxContainer.new()
	history_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	history_list.add_theme_constant_override("separation", 8)
	scroll.add_child(history_list)

func _show_history() -> void:
	_refresh_history()
	history_overlay.show()
	history_button.hide()

func _close_history() -> void:
	history_overlay.hide()
	history_button.show()

func _refresh_history() -> void:
	for child in history_list.get_children():
		child.queue_free()

	if GameData.completed_runs.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Chưa có màn nào được hoàn thành."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 18)
		history_list.add_child(empty_label)
		return

	for index in GameData.completed_runs.size():
		var run: Dictionary = GameData.completed_runs[index]
		var map_data: Dictionary = GameData.MAPS[run["map_id"]]
		var difficulty_data: Dictionary = GameData.DIFFICULTIES[run["difficulty_id"]]
		var completed_at := Time.get_datetime_string_from_unix_time(int(run.get("completed_at", 0)), true)
		var row := Label.new()
		row.text = "%d. %s | %s | %d giây | %s" % [
			index + 1,
			map_data.get("name", run["map_id"]),
			difficulty_data.get("name", run["difficulty_id"]),
			int(run.get("survival_seconds", 0)),
			completed_at
		]
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_color_override("font_color", Color(0.92, 0.91, 0.86))
		history_list.add_child(row)
