extends Control

func _ready():
	$Center/Continue.disabled = SavesManager.current == null
	$Version.text = '{0} - {1}'.format([
		ProjectSettings.get_setting("application/config/version"),
		ProjectSettings.get_setting("application/config/build_date")
	])


func _on_settings_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_SETTINGS_MENU)


func _on_credits_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_CREDITS)


func _on_exit_pressed():
	get_tree().quit()


func _on_continue_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_LEVEL_SELECT)


func _on_new_game_pressed():
	SavesManager.new_save()
	_on_continue_pressed()
