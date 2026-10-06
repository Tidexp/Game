extends Node

@export var survival_time: float = 60.0
var time_elapsed: float = 0.0
var is_game_over: bool = false

# Sửa lại đúng tên file là WinMenu.tscn (viết hoa chữ W và M)
const WIN_MENU_SCENE = preload("res://scenes/ui/winmenu.tscn")

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	time_elapsed += delta
	# In ra để theo dõi thời gian trên console
	print("Thoi gian sinh ton: ", snapped(time_elapsed, 0.1))
	
	if time_elapsed >= survival_time:
		trigger_win()

func trigger_win() -> void:
	is_game_over = true
	print("Da sinh tồn đủ 60s - WIN GAME!")
	GameData.record_completed_run(GameData.selected_map_id, GameData.selected_difficulty_id, int(time_elapsed))
	
	# Instantiate bảng Win hiển thị lên màn hình chơi game hiện tại
	var win_ui = WIN_MENU_SCENE.instantiate()
	get_tree().current_scene.add_child(win_ui)
	
	# Tạm dừng toàn bộ hoạt động trong game khi thắng
	get_tree().paused = true
