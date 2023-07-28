extends Node

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent):
	if Globals.debug_enabled:
		if event is InputEventKey and not event.is_pressed():
			if event.keycode == KEY_END:
				get_tree().quit()
			elif event.keycode == KEY_HOME:
				SavesManager.reload_save()
	
	
	if event.is_action("pause") and Input.is_action_just_pressed("pause"):
		if Globals.player != null and not Globals.is_in_cutscene:
			get_tree().paused = not get_tree().paused
		
	elif event.is_action("toggle_fullscreen") and Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == Window.MODE_FULLSCREEN:
			SettingsManager.set_setting(SettingsManager.SETTING_WINDOW_SIZE, "default")
		else:
			SettingsManager.set_setting(SettingsManager.SETTING_WINDOW_SIZE, "fullscreen")
