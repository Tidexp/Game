extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D/Player # Hoặc $Player tùy cây node của bạn
@onready var level_up_menu: Control = $CanvasLayer/LevelUpMenu
@onready var gold_label: Label = $CanvasLayer/GoldLabel

func _ready() -> void:
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
