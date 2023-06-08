extends Control


func _on_level_select_pressed():
    Butler.change_scene_to_file(Butler.SCENE_LEVEL_SELECT)
