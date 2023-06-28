extends Control


func _on_level_select_pressed():
    get_tree().change_scene_to_file(Globals.SCENE_LEVEL_SELECT)
