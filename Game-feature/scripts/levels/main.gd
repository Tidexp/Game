extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D/Player # Hoặc $Player tùy cây node của bạn
@onready var level_up_menu: Control = $CanvasLayer/LevelUpMenu
@onready var gold_label: Label = $CanvasLayer/GoldLabel
var weapons_row: HBoxContainer

const WEAPON_HUD_ITEMS := [
	{"id": "Sugarcane", "name": "Bã mía", "icon": "res://assets/sprites/weapons/sugarcane/sugarcane.png"},
	{"id": "Shisa", "name": "Shisa", "icon": "res://assets/sprites/weapons/shisa/shisa.png"},
	{"id": "Chay", "name": "Cái chày", "icon": "res://assets/sprites/weapons/bat/bat.png"},
	{"id": "Shield", "name": "Khiên", "icon": "res://assets/sprites/weapons/shield/shield.png"},
	{"id": "Phone", "name": "Điện thoại", "icon": "res://assets/sprites/weapons/phone/phone1.png"}
]

func _ready() -> void:
	_apply_selected_map()
	_update_gold_label(GameData.gold)
	GameData.gold_changed.connect(_update_gold_label)

	# Tìm lại player nếu đường dẫn phía trên bị lệch
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if player and level_up_menu:
		player.player_leveled_up.connect(_on_player_leveled_up)
		player.weapons_changed.connect(_refresh_weapons_hud)
		level_up_menu.upgrade_selected.connect(_on_upgrade_selected)
	_create_weapons_hud()
	_refresh_weapons_hud()

func _create_weapons_hud() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(20, 68)
	panel.custom_minimum_size = Vector2(320, 78)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.035, 0.04, 0.78)
	panel_style.border_color = Color(0.72, 0.62, 0.38, 0.8)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 8
	panel_style.content_margin_top = 5
	panel_style.content_margin_right = 8
	panel_style.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", panel_style)
	$CanvasLayer.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	panel.add_child(content)
	var heading := Label.new()
	heading.text = "VŨ KHÍ"
	heading.add_theme_font_size_override("font_size", 12)
	heading.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	content.add_child(heading)

	weapons_row = HBoxContainer.new()
	weapons_row.add_theme_constant_override("separation", 5)
	content.add_child(weapons_row)

func _refresh_weapons_hud() -> void:
	if not weapons_row or not player:
		return
	for item in weapons_row.get_children():
		weapons_row.remove_child(item)
		item.queue_free()

	var player_weapons: Node = player.get_node_or_null("Weapons")
	if not player_weapons:
		return
	for weapon_info in WEAPON_HUD_ITEMS:
		var weapon: Node = player_weapons.get_node_or_null(weapon_info["id"])
		if not weapon:
			continue
		var item := VBoxContainer.new()
		item.custom_minimum_size = Vector2(48, 48)
		item.add_theme_constant_override("separation", 0)
		item.tooltip_text = weapon_info["name"]
		weapons_row.add_child(item)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(34, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = load(weapon_info["icon"])
		icon.tooltip_text = weapon_info["name"]
		item.add_child(icon)

		var level_label := Label.new()
		level_label.text = "Lv.%d" % int(weapon.get("level"))
		level_label.add_theme_font_size_override("font_size", 10)
		level_label.add_theme_color_override("font_color", Color(0.9, 0.88, 0.8))
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item.add_child(level_label)

func _on_player_leveled_up(current_level: int) -> void:
	level_up_menu.show_options(current_level)

func _on_upgrade_selected(chosen_data: Dictionary) -> void:
	if player:
		player.apply_upgrade(chosen_data)

func _update_gold_label(total_gold: int) -> void:
	gold_label.text = "Vàng: %d" % total_gold

func _apply_selected_map() -> void:
	var map_data: Dictionary = GameData.MAPS.get(GameData.selected_map_id, GameData.MAPS["map_1"])
	var background_path: String = map_data.get("background_path", "")
	if background_path.is_empty() or not ResourceLoader.exists(background_path):
		return

	var source_texture := load(background_path) as Texture2D
	if not source_texture:
		return

	var target_size := Vector2(640.0, 480.0)
	var source_size := source_texture.get_size()
	var crop_size := source_size
	var target_ratio := target_size.x / target_size.y
	if source_size.x / source_size.y > target_ratio:
		crop_size.x = source_size.y * target_ratio
	else:
		crop_size.y = source_size.x / target_ratio

	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2((source_size - crop_size) * 0.5, crop_size)
	var background: Sprite2D = $Parallax2D/Sprite2D
	background.texture = atlas
	background.scale = target_size / crop_size
