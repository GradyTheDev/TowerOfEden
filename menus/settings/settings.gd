extends Control

@onready var resolution: OptionButton = $Center/Resolution
@onready var volume: SpinBox = $Center/Control/Volume
@onready var screen: OptionButton = $Center/Screen

func _ready():
	var v = ''
	# Adding Resolution Options
	var items = []
	items.append("Default - {0}x{1}".format([Butler.DEFAULT_WINDOW_SIZE.x, Butler.DEFAULT_WINDOW_SIZE.y]))
	items.append('fullscreen')
	for i in resolution.item_count:
		var txt := resolution.get_item_text(i)
		var arr := txt.split('x')
		if arr.size() == 2 and arr[0].is_valid_int() and arr[1].is_valid_int():
			items.append(txt)
	
	resolution.clear()
	for item in items:
		resolution.add_item(item)
	
	# todo: Load Resolution from save
	v = Butler.settings[Butler.SETTING_WINDOW_SIZE]
	if v.to_lower().contains('default'):
		resolution.select(0)
	elif v == 'fullscreen':
		resolution.select(1)
	else:
		var found = false
		for i in range(len(items)):
			if items[i] == v:
				resolution.select(i)
				found = true
				break
		if not found:
			items.append(v)
			resolution.add_item(v)
			resolution.select(items.size()-1)
	
	# Load volume from save
	volume.value = Butler.settings.get(Butler.SETTING_MASTER_VOLUME, 0)

	# Add Screen Options
	screen.clear()
	screen.add_item('current')
	screen.add_item('primary')
	for i in DisplayServer.get_screen_count():
		var screen_size := DisplayServer.screen_get_size(i)
		screen.add_item("{0}: {1}x{2}".format(
			[
				i, 
				screen_size.x,
				screen_size.y
			]))
	
	# Load Screen Option from save
	v = Butler.settings[Butler.SETTING_SCREEN]
	if v == 'current':
		screen.select(0)
	elif v == 'primary':
		screen.select(1)
	else:
		screen.select(int(v)+2)

func _on_back_pressed():
	Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)


func _on_resolution_item_selected(index):	
	if index == 0:
		Butler.set_setting(Butler.SETTING_WINDOW_SIZE, 'default')
	elif index == 1:
		Butler.set_setting(Butler.SETTING_WINDOW_SIZE, 'fullscreen')
	else:
		Butler.set_setting(Butler.SETTING_WINDOW_SIZE, resolution.get_item_text(index))


func _on_volume_value_changed(value: float):
	Butler.set_setting(Butler.SETTING_MASTER_VOLUME, value)


func _on_screen_item_selected(index:int):
	var v = ''
	if index > 1:
		Butler.set_setting(Butler.SETTING_SCREEN, str(index-2))
	else:
		Butler.set_setting(Butler.SETTING_SCREEN, screen.get_item_text(index))


func _on_open_save_location_pressed():
	OS.shell_open(OS.get_user_data_dir())
