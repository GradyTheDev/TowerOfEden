extends Control

func _ready():
	$Center/Continue.disabled = Butler.save.size() == 0


func _on_settings_pressed():
	Butler.change_scene_to_file(Butler.SCENE_SETTINGS_MENU)


func _on_credits_pressed():
	Butler.change_scene_to_file(Butler.SCENE_CREDITS)


func _on_exit_pressed():
	Butler.safe_exit()


func _on_continue_pressed():
	Butler.start_game()


func _on_new_game_pressed():
	Butler.new_game()
	Butler.start_game()
