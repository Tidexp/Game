extends Node

signal gold_changed(total_gold: int)

const SAVE_PATH := "user://profile.cfg"
const CHARACTERS := {
	"default": {
		"name": "Nhân vật mặc định",
		"price": 0,
		"portrait_path": "res://assets/sprites/player/character_selection.png",
		"sprite_path": ""
	},
	"red_hair": {
		"name": "Nhân vật mới",
		"price": 100,
		"portrait_path": "res://assets/sprites/player/new_character.png",
		"normal_path": "res://assets/sprites/player/new_character_normal.png",
		"jump_path": "res://assets/sprites/player/new_character_jump.png",
		"attack_path": "res://assets/sprites/player/new_character_attack.png"
	}
}

var gold: int = 0
var unlocked_characters: Array[String] = ["default"]
var selected_character_id: String = "default"

func _ready() -> void:
	_load_profile()

func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	_save_profile()
	gold_changed.emit(gold)

func is_character_unlocked(character_id: String) -> bool:
	return unlocked_characters.has(character_id)

func purchase_character(character_id: String) -> bool:
	var character: Dictionary = CHARACTERS.get(character_id, {})
	if character.is_empty() or is_character_unlocked(character_id):
		return false

	var price: int = character.get("price", 0)
	if gold < price:
		return false

	gold -= price
	unlocked_characters.append(character_id)
	_save_profile()
	gold_changed.emit(gold)
	return true

func select_character(character_id: String) -> bool:
	if not CHARACTERS.has(character_id) or not is_character_unlocked(character_id):
		return false
	selected_character_id = character_id
	_save_profile()
	return true

func _load_profile() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		_save_profile()
		return

	gold = maxi(0, int(config.get_value("profile", "gold", 0)))
	unlocked_characters.clear()
	var saved_characters: Array = config.get_value("profile", "unlocked_characters", ["default"])
	for character_id in saved_characters:
		if character_id is String and CHARACTERS.has(character_id) and not unlocked_characters.has(character_id):
			unlocked_characters.append(character_id)
	if not unlocked_characters.has("default"):
		unlocked_characters.push_front("default")

	var saved_selection: String = config.get_value("profile", "selected_character_id", "default")
	selected_character_id = saved_selection if is_character_unlocked(saved_selection) else "default"

func _save_profile() -> void:
	var config := ConfigFile.new()
	config.set_value("profile", "gold", gold)
	config.set_value("profile", "unlocked_characters", unlocked_characters)
	config.set_value("profile", "selected_character_id", selected_character_id)
	config.save(SAVE_PATH)
