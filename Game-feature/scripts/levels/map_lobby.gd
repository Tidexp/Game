extends Control

const CHARACTER_LOBBY_PATH := "res://scenes/levels/character_lobby.tscn"
const DIFFICULTY_LOBBY_PATH := "res://scenes/levels/difficulty_lobby.tscn"
const MAP_IDS: Array[String] = ["map_1", "map_2", "map_3"]

var map_cards: Dictionary = {}
var map_select_buttons: Dictionary = {}
var selected_map_label: Label

func _ready() -> void:
	_build_ui()
	_refresh_maps()

func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/main_menu/background.jpg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var overlay := ColorRect.new()
	overlay.color = Color(0.025, 0.035, 0.045, 0.78)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	margin.add_child(content)

	var header := HBoxContainer.new()
	content.add_child(header)

	var heading := Label.new()
	heading.text = "CHỌN BẢN ĐỒ"
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	header.add_child(heading)

	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)

	selected_map_label = Label.new()
	selected_map_label.add_theme_font_size_override("font_size", 18)
	selected_map_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.83))
	header.add_child(selected_map_label)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 18)
	content.add_child(cards_row)

	for map_id in MAP_IDS:
		cards_row.add_child(_create_map_card(map_id))

	var footer := HBoxContainer.new()
	content.add_child(footer)

	var back_button := _make_button("Quay lại")
	back_button.pressed.connect(_on_back_pressed)
	footer.add_child(back_button)

	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)

	var start_button := _make_button("Chọn độ khó")
	start_button.custom_minimum_size = Vector2(220, 52)
	start_button.pressed.connect(_on_start_pressed)
	footer.add_child(start_button)

func _create_map_card(map_id: String) -> PanelContainer:
	var map_data: Dictionary = GameData.MAPS[map_id]
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(300, 390)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_cards[map_id] = card

	var details := VBoxContainer.new()
	details.add_theme_constant_override("separation", 12)
	card.add_child(details)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(280, 235)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var background_path: String = map_data.get("background_path", "")
	if ResourceLoader.exists(background_path):
		preview.texture = load(background_path)
	details.add_child(preview)

	var title := Label.new()
	title.text = map_data.get("name", map_id)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86))
	details.add_child(title)

	var description := Label.new()
	description.text = map_data.get("description", "")
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_color_override("font_color", Color(0.8, 0.79, 0.74))
	details.add_child(description)

	var select_button := _make_button("Chọn map")
	select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_button.pressed.connect(_on_select_map_pressed.bind(map_id))
	details.add_child(select_button)
	map_select_buttons[map_id] = select_button
	return card

func _make_button(button_text: String) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(120, 44)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _refresh_maps() -> void:
	for map_id in MAP_IDS:
		var is_selected := GameData.selected_map_id == map_id
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.08, 0.075, 0.065, 0.96)
		style.border_color = Color(1.0, 0.78, 0.24) if is_selected else Color(0.4, 0.4, 0.38)
		style.set_border_width_all(3 if is_selected else 1)
		style.set_corner_radius_all(8)
		style.content_margin_left = 12
		style.content_margin_top = 12
		style.content_margin_right = 12
		style.content_margin_bottom = 12
		var card: PanelContainer = map_cards[map_id]
		card.add_theme_stylebox_override("panel", style)
		var select_button: Button = map_select_buttons[map_id]
		select_button.text = "Đang chọn" if is_selected else "Chọn map"
		select_button.disabled = is_selected

	var selected_data: Dictionary = GameData.MAPS[GameData.selected_map_id]
	selected_map_label.text = "Đang chọn: %s" % selected_data.get("name", GameData.selected_map_id)

func _on_select_map_pressed(map_id: String) -> void:
	GameData.select_map(map_id)
	_refresh_maps()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(CHARACTER_LOBBY_PATH)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(DIFFICULTY_LOBBY_PATH)
