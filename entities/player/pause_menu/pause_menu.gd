extends Control


func _on_level_select_pressed():
    Butler.change_scene_to_file(Butler.SCENE_LEVEL_SELECT)


func _on_exit_pressed():
    Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)