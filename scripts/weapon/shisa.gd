class_name Shisa
extends Node2D

var weapon_name: String = "Shisa"
var level: int = 1
const MAX_LEVEL: int = 8

# Thông số trạng thái
var attack_duration: float = 5.0   # Thời gian duy trì phun (giây)
var attack_cooldown: float = 3.0   # Thời gian hồi chiêu sau khi phun xong (giây)
var damage_per_tick: int = 15      # Sát thương mỗi nhịp
var effect_scale: float = 1.0

var is_attacking: bool = false
var state_timer: float = 0.0

@onready var attack_area: Area2D = $ShisaAttack

const UPGRADE_DESCRIPTIONS = {
	2: "Tăng +5 sát thương mỗi nhịp",
	3: "Kéo dài thời gian phun thêm 0.5 giây",
	4: "Phóng to phạm vi luồng khói 25%",
	5: "Giảm 25% thời gian hồi chiêu",
	6: "Tăng tiếp +8 sát thương mỗi nhịp",
	7: "Mở rộng tiếp 25% phạm vi khói",
	8: "MAX: Phun cực lâu, sát thương cực lớn và hồi siêu nhanh"
}

func _ready() -> void:
	state_timer = 0.0
	is_attacking = false
	if attack_area:
		attack_area.stop_attack()

func _process(delta: float) -> void:
	state_timer += delta
	
	if is_attacking:
		aim_at_nearest_enemy()
		
		if state_timer >= attack_duration:
			is_attacking = false
			state_timer = 0.0
			attack_area.stop_attack()
	else:
		if state_timer >= attack_cooldown:
			var enemies = get_tree().get_nodes_in_group("enemies")
			if not enemies.is_empty():
				is_attacking = true
				state_timer = 0.0
				aim_at_nearest_enemy()
				# Truyền cả sát thương lẫn scale vào attack_area để tránh bị Tween ghi đè
				attack_area.start_attack(damage_per_tick, effect_scale)

func aim_at_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
		
	var nearest_enemy = enemies[0]
	var min_dist = global_position.distance_to(nearest_enemy.global_position)
	for enemy in enemies:
		var d = global_position.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			nearest_enemy = enemy
			
	var dir = global_position.direction_to(nearest_enemy.global_position)
	attack_area.rotation = dir.angle()

func upgrade() -> void:
	if level >= MAX_LEVEL:
		return
	level += 1
	match level:
		2:
			damage_per_tick += 5
		3:
			attack_duration += 0.5
		4:
			effect_scale *= 1.25
		5:
			attack_cooldown *= 0.75
		6:
			damage_per_tick += 8
		7:
			effect_scale *= 1.25
		8:
			damage_per_tick += 12
			attack_duration += 1.0
			attack_cooldown *= 0.7
			
	# Cập nhật ngay lập tức nếu đang trong lúc phun
	if is_attacking and attack_area:
		attack_area.damage = damage_per_tick
		attack_area.scale = Vector2(effect_scale, effect_scale)
			
	print("Shisa lên Lv ", level, " | Dmg: ", damage_per_tick, " | Phun: ", attack_duration, "s | CD: ", attack_cooldown, "s")
