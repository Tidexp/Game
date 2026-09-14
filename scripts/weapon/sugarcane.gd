extends Node2D

@export var attack_scene: PackedScene = preload("res://scenes/weapon/sugarcane_attack.tscn")

var weapon_name: String = "Sugarcane"
var level: int = 1
const MAX_LEVEL: int = 8

var attack_cooldown: float = 0.8
var damage: int = 20
var bullet_count: int = 1
var attack_speed: float = 500.0
var attack_timer: float = 0.0

const UPGRADE_DESCRIPTIONS = {
	2: "Tăng +10 sát thương",
	3: "Giảm 20% thời gian hồi chiêu",
	4: "Tăng tốc độ bay thêm 150",
	5: "Bắn tỏa 2 tia đạn cùng lúc",
	6: "Giảm tiếp 20% hồi chiêu",
	7: "Tăng cực mạnh sát thương (+20)",
	8: "MAX: Bắn tỏa 3 tia chùm"
}

func _process(delta: float) -> void:
	attack_timer += delta
	if attack_timer >= attack_cooldown:
		attack_timer = 0.0
		attack()

func attack() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
		
	# Tìm quái gần nhất
	var nearest_enemy = enemies[0]
	var min_distance = global_position.distance_to(nearest_enemy.global_position)
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			nearest_enemy = enemy
			
	var base_direction = global_position.direction_to(nearest_enemy.global_position)
	
	# Bắn theo số lượng tia tương ứng với level
	for i in range(bullet_count):
		var projectile = attack_scene.instantiate()
		projectile.global_position = global_position
		
		# Tính góc lệch nếu bắn nhiều tia
		var spread_angle = 0.0
		if bullet_count == 2:
			spread_angle = deg_to_rad(-12.0 if i == 0 else 12.0)
		elif bullet_count == 3:
			spread_angle = deg_to_rad(-18.0 if i == 0 else (0.0 if i == 1 else 18.0))
			
		var final_dir = base_direction.rotated(spread_angle)
		if "direction" in projectile:
			projectile.direction = final_dir
		if "damage" in projectile:
			projectile.damage = damage
		if "speed" in projectile:
			projectile.speed = attack_speed
			
		get_tree().current_scene.add_child(projectile)

func upgrade() -> void:
	if level >= MAX_LEVEL:
		return
	level += 1
	match level:
		2: damage += 10
		3: attack_cooldown *= 0.8
		4: attack_speed += 150.0
		5: bullet_count = 2
		6: attack_cooldown *= 0.8
		7: damage += 20
		8: bullet_count = 3
	print("Sugarcane lên Level: ", level, " | Dmg: ", damage, " | Cooldown: ", attack_cooldown)
