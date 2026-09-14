extends Control

signal upgrade_selected(chosen_data: Dictionary)

@onready var buttons: Array[Button] = [
	$Panel/VBoxContainer/OptionBtn1,
	$Panel/VBoxContainer/OptionBtn2,
	$Panel/VBoxContainer/OptionBtn3
]

# Cơ sở dữ liệu vũ khí
const WEAPON_DATABASE = {
	"Sugarcane": {
		"name": "Bã mía",
		"desc": "Phóng mía về phía kẻ địch gần nhất",
		"scene": preload("res://scenes/weapon/sugarcane.tscn"),
		"icon": preload("res://assets/sprites/weapons/sugarcane/sugarcane.png") 
	},
	"Shisa": {
		"name": "Shisa",
		"desc": "Phun làn khói liên tục diện rộng",
		"scene": preload("res://scenes/weapon/shisa.tscn"),
		"icon": preload("res://assets/sprites/weapons/shisa/shisa.png")      
	},
	"Chay": {
		"name": "Cái chày",
		"desc": "Vung chày đập mạnh xuống đầu kẻ địch cận chiến",
		"scene": preload("res://scenes/weapon/bat.tscn"),
		"icon": preload("res://assets/sprites/weapons/bat/bat.png")      
	}
}

# Icon thẻ bổ trợ
const STAT_ICONS = {
	"heal": preload("res://assets/sprites/weapons/default/heart.png"),
	"speed": preload("res://assets/sprites/weapons/default/boot.png")
}

var current_options: Array = []

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.pressed.connect(_on_btn_pressed.bind(i))
		
		# 1. Xóa sạch icon mặc định và chữ mặc định của Button để tránh bị vẽ đè ảnh to
		btn.icon = null
		btn.text = ""
		btn.custom_minimum_size = Vector2(360, 64)
		
		# 2. Tự động chuẩn hóa HBoxContainer bên trong
		var hbox = btn.get_node_or_null("HBoxContainer")
		if hbox:
			hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			# Thêm khoảng đệm viền nếu muốn đẹp mắt
			if hbox is BoxContainer:
				hbox.add_theme_constant_override("separation", 12)
		
		# 3. Tự động khóa chết kích thước của TextureRect bằng code
		var icon_node: TextureRect = btn.get_node_or_null("HBoxContainer/Icon") as TextureRect
		if icon_node:
			icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_node.custom_minimum_size = Vector2(48, 48)
			icon_node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# 4. Tự động bật mở rộng ngang cho khung chứa chữ
		var text_container = btn.get_node_or_null("HBoxContainer/TextContainer")
		if text_container:
			text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text_container.alignment = BoxContainer.ALIGNMENT_CENTER
			
		var desc_node: Label = btn.get_node_or_null("HBoxContainer/TextContainer/Desc") as Label
		if desc_node:
			desc_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func show_options(_level: int = 1) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	var weapons_node = player.get_node_or_null("Weapons")
	var new_weapon_options: Array = []
	var upgrade_options: Array = []

	# 1. Phân loại MỚI hoặc NÂNG CẤP từ cơ sở dữ liệu
	for weapon_id in WEAPON_DATABASE.keys():
		var info = WEAPON_DATABASE[weapon_id]
		var existing_weapon = weapons_node.get_node_or_null(weapon_id) if weapons_node else null
		
		if existing_weapon == null:
			new_weapon_options.append({
				"type": "new_weapon",
				"id": weapon_id,
				"scene": info["scene"],
				"icon": info["icon"],
				"title": "[MỚI] " + info["name"],
				"desc": info["desc"]
			})
		else:
			if existing_weapon.level < existing_weapon.MAX_LEVEL:
				var next_lv = existing_weapon.level + 1
				var desc_text = existing_weapon.UPGRADE_DESCRIPTIONS.get(next_lv, "Cải thiện sức mạnh")
				upgrade_options.append({
					"type": "upgrade_weapon",
					"id": weapon_id,
					"icon": info["icon"],
					"title": info["name"] + " (Lv " + str(next_lv) + ")",
					"desc": desc_text
				})

	new_weapon_options.shuffle()
	upgrade_options.shuffle()

	# 2. Tạo pool lựa chọn
	var final_pool: Array = []
	final_pool.append_array(new_weapon_options)
	final_pool.append_array(upgrade_options)

	# 3. Bổ sung các thẻ chỉ số phụ
	var stat_options = [
		{
			"type": "stat", 
			"id": "heal", 
			"icon": STAT_ICONS.get("heal"), 
			"title": "Hồi Máu", 
			"desc": "Hồi lại 30 điểm HP ngay lập tức"
		},
		{
			"type": "stat", 
			"id": "speed", 
			"icon": STAT_ICONS.get("speed"), 
			"title": "Tăng Tốc Chạy", 
			"desc": "Tăng thêm 15% tốc độ di chuyển"
		}
	]
	stat_options.shuffle()
	final_pool.append_array(stat_options)

	current_options = final_pool.slice(0, 3)

	# 4. Hiển thị UI với Icon thu nhỏ chuẩn và Text không bị tràn
	for i in range(buttons.size()):
		var btn = buttons[i]
		if i < current_options.size():
			var data = current_options[i]
			btn.visible = true
			
			# Luôn dọn icon mặc định của Button
			btn.icon = null
			
			# Gán Texture cho node con TextureRect
			var icon_node: TextureRect = btn.get_node_or_null("HBoxContainer/Icon") as TextureRect
			if icon_node:
				icon_node.texture = data.get("icon", null)
			
			# Gán Title & Desc
			var title_node: Label = btn.get_node_or_null("HBoxContainer/TextContainer/Title") as Label
			var desc_node: Label = btn.get_node_or_null("HBoxContainer/TextContainer/Desc") as Label
			if title_node:
				title_node.text = data.get("title", "")
			if desc_node:
				desc_node.text = data.get("desc", "")
		else:
			btn.visible = false
			
	show()
	get_tree().paused = true

func _on_btn_pressed(index: int) -> void:
	if index < current_options.size():
		var chosen_data = current_options[index]
		hide()
		get_tree().paused = false
		upgrade_selected.emit(chosen_data)
