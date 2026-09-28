extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D/Player # Hoặc $Player tùy cây node của bạn
@onready var level_up_menu: Control = $CanvasLayer/LevelUpMenu
@onready var gold_label: Label = $CanvasLayer/GoldLabel

func _ready() -> void:
	_apply_selected_map()
	_update_gold_label(GameData.gold)
	GameData.gold_changed.connect(_update_gold_label)

	# Tìm lại player nếu đường dẫn phía trên bị lệch
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if player and level_up_menu:
		player.player_leveled_up.connect(_on_player_leveled_up)
		level_up_menu.upgrade_selected.connect(_on_upgrade_selected)

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
