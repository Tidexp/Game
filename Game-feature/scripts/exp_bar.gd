extends ProgressBar

func _ready() -> void:
	# Đợi một nhịp để chắc chắn Player đã được load vào Scene Tree
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		max_value = player.max_exp
		value = player.current_exp
		# Kết nối an toàn với signal của player
		if not player.is_connected("exp_changed", _on_player_exp_changed):
			player.exp_changed.connect(_on_player_exp_changed)
	else:
		print("Không tìm thấy node Player trong group 'player'!")

func _on_player_exp_changed(current_exp: int, max_exp: int) -> void:
	max_value = max_exp
	var tween = create_tween()
	tween.tween_property(self, "value", current_exp, 0.2)
