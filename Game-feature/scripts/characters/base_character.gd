class_name BaseCharacter
extends CharacterBody2D

# --- CHỈ SỐ CƠ BẢN ---
@export var max_health: int = 100
var health: int = 100
var is_dead: bool = false

# --- HỆ THỐNG I-FRAME TOÀN CỤC ---
@export var iframe_duration: float = 1.0
var iframe_timer: float = 0.0
var is_invincible: bool = false
var flash_tween: Tween

# Node UI máu (nếu nhân vật có)
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")
@onready var health_label: Label = get_node_or_null("HealthBar/HealthLabel")

func _ready() -> void:
	health = max_health
	update_health_ui()

func _physics_process(delta: float) -> void:
	# Tự động đếm thời gian I-frame cho bất kỳ nhân vật nào
	if is_invincible:
		iframe_timer -= delta
		if iframe_timer <= 0.0:
			end_iframes()

func take_damage(amount: int) -> void:
	if is_dead or is_invincible:
		return
		
	health = clamp(health - amount, 0, max_health)
	update_health_ui()
	
	if health <= 0:
		is_dead = true
		die()
	else:
		start_iframes()

func start_iframes() -> void:
	is_invincible = true
	iframe_timer = iframe_duration
	
	# Hủy animation nhấp nháy cũ nếu đang chạy dở
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
		
	# Nhấp nháy mờ báo hiệu bất tử
	flash_tween = create_tween().set_loops(int(iframe_duration / 0.16))
	flash_tween.tween_property(self, "modulate:a", 0.3, 0.08)
	flash_tween.tween_property(self, "modulate:a", 1.0, 0.08)

func end_iframes() -> void:
	is_invincible = false
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	modulate.a = 1.0

func update_health_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if health_label:
		health_label.text = str(health) + " / " + str(max_health)

func die() -> void:
	modulate.a = 1.0
	set_physics_process(false)
	print(name, " đã chết!")
