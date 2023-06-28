extends Control


func _on_exit_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_MAIN_MENU)
