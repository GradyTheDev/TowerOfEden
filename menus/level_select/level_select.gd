extends Control

func _ready():
	$Center/Debug.visible = Butler.is_debug_enabled()
	$Center/DebugSep.visible = Butler.is_debug_enabled()


func _on_exit_pressed():
	Butler.save_game()
	Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)


func _on_city_pressed():
	Butler.change_scene_to_file("res://floors/city/city_floor.tscn")

func _on_level2_pressed():
	Butler.change_scene_to_file("res://floors/level_2/level_2.tscn")


func _on_debug_pressed():
	Butler.change_scene_to_file("res://floors/entity_testing/entity_testing.tscn")
