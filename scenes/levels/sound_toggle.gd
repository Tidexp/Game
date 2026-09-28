extends CheckButton

func _ready() -> void:
	# Lấy vị trí của Audio Bus "BG" (Background Music)
	var bg_bus = AudioServer.get_bus_index("BG")
	
	# Đồng bộ trạng thái ban đầu của nút với bus BG
	button_pressed = !AudioServer.is_bus_mute(bg_bus) # CheckButton sáng là bật, nên ngược lại với mute
	
	# Lắng nghe sự kiện khi người dùng gạt công tắc
	toggled.connect(_on_toggled)

func _on_toggled(button_pressed: bool) -> void:
	var bg_bus = AudioServer.get_bus_index("BG")
	
	# Nếu bật (true) thì mở nhạc nền BG (mute = false), nếu tắt thì mute = true
	AudioServer.set_bus_mute(bg_bus, !button_pressed)
	
	if button_pressed:
		print("Đã bật nhạc nền (BG)!")
	else:
		print("Đã tắt nhạc nền (BG)! Nhạc vùng cấm (DR) vẫn hoạt động.")
