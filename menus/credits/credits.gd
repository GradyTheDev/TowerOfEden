extends Control


func _on_exit_pressed():
	Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)
