extends Control

const MAIN_MENU_PATH := "res://scenes/levels/main_menu.tscn"
const MAP_LOBBY_PATH := "res://scenes/levels/map_lobby.tscn"
const FALLBACK_PORTRAIT_PATH := "res://assets/sprites/player/character_selection.png"

var character_ids: Array[String] = []
var selected_index: int = 0
var preview: TextureRect
var name_label: Label
var status_label: Label
var balance_label: Label
var action_button: Button

func _ready() -> void:
	for character_id in GameData.CHARACTERS.keys():
		character_ids.append(character_id)
	_build_ui()
	GameData.gold_changed.connect(_on_gold_changed)
	_refresh_character()

func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = load("res://assets/main_menu/background.jpg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var overlay := ColorRect.new()
	overlay.color = Color(0.03, 0.025, 0.02, 0.72)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	margin.add_child(content)

	var header := HBoxContainer.new()
	content.add_child(header)

	var heading := Label.new()
	heading.text = "SẢNH NHÂN VẬT"
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	header.add_child(heading)

	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)

	balance_label = Label.new()
	balance_label.add_theme_font_size_override("font_size", 22)
	balance_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	header.add_child(balance_label)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 410)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.07, 0.055, 0.94)
	panel_style.border_color = Color(0.78, 0.56, 0.18, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 24
	panel_style.content_margin_top = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_style)
	content.add_child(panel)

	var details := HBoxContainer.new()
	details.add_theme_constant_override("separation", 32)
	panel.add_child(details)

	preview = TextureRect.new()
	preview.custom_minimum_size = Vector2(270, 350)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	details.add_child(preview)

	var information := VBoxContainer.new()
	information.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	information.add_theme_constant_override("separation", 16)
	details.add_child(information)

	var section_label := Label.new()
	section_label.text = "NHÂN VẬT"
	section_label.add_theme_font_size_override("font_size", 14)
	section_label.add_theme_color_override("font_color", Color(0.78, 0.74, 0.64))
	information.add_child(section_label)

	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86))
	information.add_child(name_label)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	information.add_child(status_label)

	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 12)
	information.add_child(navigation)
	var previous_button := _make_button("Trước")
	previous_button.pressed.connect(_show_previous_character)
	navigation.add_child(previous_button)
	var next_button := _make_button("Tiếp")
	next_button.pressed.connect(_show_next_character)
	navigation.add_child(next_button)

	var flexible_space := Control.new()
	flexible_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	information.add_child(flexible_space)

	action_button = _make_button("Mua nhân vật")
	action_button.custom_minimum_size = Vector2(0, 52)
	action_button.pressed.connect(_on_action_pressed)
	information.add_child(action_button)

	var footer := HBoxContainer.new()
	content.add_child(footer)
	var back_button := _make_button("Quay lại")
	back_button.pressed.connect(_on_back_pressed)
	footer.add_child(back_button)
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	var start_button := _make_button("Vào game")
	start_button.custom_minimum_size = Vector2(220, 52)
	start_button.pressed.connect(_on_start_pressed)
	footer.add_child(start_button)

func _make_button(button_text: String) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(120, 44)
	button.add_theme_font_size_override("font_size", 18)
	return button

func _refresh_character() -> void:
	if character_ids.is_empty():
		return
	selected_index = posmod(selected_index, character_ids.size())
	var character_id := character_ids[selected_index]
	var character: Dictionary = GameData.CHARACTERS[character_id]
	name_label.text = character.get("name", character_id)

	var portrait_path: String = character.get("portrait_path", FALLBACK_PORTRAIT_PATH)
	if not ResourceLoader.exists(portrait_path):
		portrait_path = FALLBACK_PORTRAIT_PATH
	preview.texture = load(portrait_path)

	var unlocked := GameData.is_character_unlocked(character_id)
	if unlocked:
		status_label.text = "Đã mở khóa"
		var is_selected := GameData.selected_character_id == character_id
		action_button.text = "Đang chọn" if is_selected else "Chọn nhân vật"
		action_button.disabled = is_selected
	else:
		var price: int = character.get("price", 0)
		status_label.text = "Giá: %d vàng" % price
		action_button.text = "Mua nhân vật"
		action_button.disabled = GameData.gold < price
	balance_label.text = "Vàng: %d" % GameData.gold

func _show_previous_character() -> void:
	selected_index -= 1
	_refresh_character()

func _show_next_character() -> void:
	selected_index += 1
	_refresh_character()

func _on_action_pressed() -> void:
	var character_id := character_ids[selected_index]
	if GameData.is_character_unlocked(character_id):
		GameData.select_character(character_id)
	else:
		GameData.purchase_character(character_id)
	_refresh_character()

func _on_gold_changed(_total_gold: int) -> void:
	_refresh_character()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(MAP_LOBBY_PATH)
