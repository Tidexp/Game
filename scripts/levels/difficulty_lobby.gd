extends Control

const MAP_LOBBY_PATH := "res://scenes/levels/map_lobby.tscn"
const GAME_SCENE_PATH := "res://scenes/levels/main.tscn"
const DIFFICULTY_IDS: Array[String] = ["easy", "hard", "super_hard"]

var difficulty_cards: Dictionary = {}
var difficulty_buttons: Dictionary = {}
var selected_map_label: Label
var selected_difficulty_label: Label

func _ready() -> void:
	_build_ui()
	_refresh_difficulties()

func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/main_menu/background.jpg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var overlay := ColorRect.new()
	overlay.color = Color(0.025, 0.035, 0.045, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	margin.add_child(content)

	var heading := Label.new()
	heading.text = "CHỌN ĐỘ KHÓ"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 32)
	heading.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	content.add_child(heading)

	selected_map_label = Label.new()
	selected_map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_map_label.add_theme_font_size_override("font_size", 18)
	selected_map_label.add_theme_color_override("font_color", Color(0.88, 0.87, 0.81))
	content.add_child(selected_map_label)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 20)
	content.add_child(cards_row)

	for difficulty_id in DIFFICULTY_IDS:
		cards_row.add_child(_create_difficulty_card(difficulty_id))

	selected_difficulty_label = Label.new()
	selected_difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_difficulty_label.add_theme_font_size_override("font_size", 18)
	selected_difficulty_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	content.add_child(selected_difficulty_label)

	var footer := HBoxContainer.new()
	content.add_child(footer)

	var back_button := _make_button("Quay lại chọn map")
	back_button.pressed.connect(_on_back_pressed)
	footer.add_child(back_button)

	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)

	var start_button := _make_button("Bắt đầu")
	start_button.custom_minimum_size = Vector2(220, 52)
	start_button.pressed.connect(_on_start_pressed)
	footer.add_child(start_button)

func _create_difficulty_card(difficulty_id: String) -> PanelContainer:
	var difficulty: Dictionary = GameData.DIFFICULTIES[difficulty_id]
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(300, 280)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_cards[difficulty_id] = card

	var details := VBoxContainer.new()
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_theme_constant_override("separation", 20)
	card.add_child(details)

	var title := Label.new()
	title.text = difficulty.get("name", difficulty_id)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86))
	details.add_child(title)

	var spawn_label := Label.new()
	spawn_label.text = difficulty.get("description", "")
	spawn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spawn_label.add_theme_font_size_override("font_size", 20)
	spawn_label.add_theme_color_override("font_color", Color(0.9, 0.87, 0.79))
	details.add_child(spawn_label)

	var select_button := _make_button("Chọn")
	select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_button.pressed.connect(_on_select_difficulty_pressed.bind(difficulty_id))
	details.add_child(select_button)
	difficulty_buttons[difficulty_id] = select_button
	return card

func _make_button(button_text: String) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _refresh_difficulties() -> void:
	var map_data: Dictionary = GameData.MAPS.get(GameData.selected_map_id, GameData.MAPS["map_1"])
	selected_map_label.text = "Bản đồ: %s" % map_data.get("name", "")

	for difficulty_id in DIFFICULTY_IDS:
		var is_selected := GameData.selected_difficulty_id == difficulty_id
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.075, 0.08, 0.085, 0.96)
		style.border_color = Color(1.0, 0.78, 0.24) if is_selected else Color(0.4, 0.43, 0.45)
		style.set_border_width_all(3 if is_selected else 1)
		style.set_corner_radius_all(8)
		style.content_margin_left = 20
		style.content_margin_top = 20
		style.content_margin_right = 20
		style.content_margin_bottom = 20
		var card: PanelContainer = difficulty_cards[difficulty_id]
		card.add_theme_stylebox_override("panel", style)
		var select_button: Button = difficulty_buttons[difficulty_id]
		select_button.text = "Đang chọn" if is_selected else "Chọn"
		select_button.disabled = is_selected

	var selected_data: Dictionary = GameData.DIFFICULTIES[GameData.selected_difficulty_id]
	selected_difficulty_label.text = "Độ khó đã chọn: %s" % selected_data.get("name", "")

func _on_select_difficulty_pressed(difficulty_id: String) -> void:
	GameData.select_difficulty(difficulty_id)
	_refresh_difficulties()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAP_LOBBY_PATH)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
