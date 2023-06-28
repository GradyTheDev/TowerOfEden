extends Node

# todo: Completly overhaul this to look like [save_manager.gd]

const SETTING_WINDOW_SIZE := 'graphics:window_size'
const SETTING_SCREEN := 'graphics:screen'
const SETTING_MASTER_VOLUME := 'audio:master_volume'
const SETTING_DEBUG := 'other:debug'

const FILE_SETTINGS := "user://settings.ini"

var DEFAULT_WINDOW_SIZE := Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
	)

## READONLY
var _default := {
	# 'default', 'fullscreen', 'width'x'height'
	SETTING_WINDOW_SIZE: 'default',

	# 'current', 'primary', or positive int
	SETTING_SCREEN: 'primary',

	SETTING_MASTER_VOLUME: 0,

	SETTING_DEBUG: OS.is_debug_build()
}

## DON'T SET THIS DIRECTLY
var _current := ConfigFile.new()


func _ready():
	load_from_file()
	if not FileAccess.file_exists(FILE_SETTINGS):
		save_to_file()


func save_to_file():
	_current.save(FILE_SETTINGS)


func load_from_file():
	var a = ConfigFile.new()
	var err = a.load(FILE_SETTINGS)
	if err != OK: 
		print_debug("Failed to load settings: ", error_string(err))
		for combined_key in _default:
			set_setting(combined_key, _default[combined_key])
		save_to_file()

	for combined_key in _default:
		var b = combined_key.split(':')
		if a.has_section_key(b[0], b[1]):
			set_setting(combined_key, a.get_value(b[0], b[1]))
		else:
			set_setting(combined_key, _default[combined_key])


func get_setting(combined_key: String) -> Variant:
	var a = combined_key.split(':')
	if a.size() != 2: return null
	var section = a[0]
	var key = a[1]
	if _current.has_section_key(section, key):
		return _current.get_value(section, key, null)
	else:
		return null


func set_setting(combined_key: String, value: Variant):
	if not _default.has(combined_key): return
	var a = combined_key.split(':')
	if a.size() != 2: return
	var section = a[0]
	var key = a[1]
	
	var type = typeof(value)
	match combined_key:
		SETTING_DEBUG:
			if type == TYPE_BOOL:
				Globals.debug_enabled = value
				_current.set_value(section, key, value)
			else:
				_current.set_value(section, key, OS.is_debug_build())
		
		SETTING_MASTER_VOLUME:
			if type == TYPE_INT:
				value = float(value)
				type = TYPE_FLOAT
			
			if type == TYPE_FLOAT:
				value = clampf(value, -30, 10)
				value = snappedf(value, 0.01)
				_current.set_value(section, key, value)
			else:
				_current.set_value(section, key, _default[combined_key])
			
			value = _current.get_value(section, key)
			AudioServer.set_bus_volume_db(0, value)
		
		SETTING_SCREEN:
			var current = get_window().current_screen
			var mode = DisplayServer.window_get_mode()

			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

			if type == TYPE_INT or (type == TYPE_STRING and value.is_valid_int()):
				value = int(value) # str -> int
				if value >= 0 and value < DisplayServer.get_screen_count():
					get_window().current_screen = value
					_current.set_value(section, key, value)
				else:
					_current.set_value(section, key, _default[combined_key])
			
			elif type == TYPE_STRING:
				if value == 'primary':
					get_window().current_screen = DisplayServer.get_primary_screen()
					_current.set_value(section, key, value)
				
				elif value == 'current':
					# get_window().current_screen = current
					_current.set_value(section, key, value)
					
				else:
					_current.set_value(section, key, _default[combined_key])
			
			else:
				_current.set_value(section, key, _default[combined_key])
				pass # incorrect value
			
			# Wait for the window to change screens before setting mode, else glitches
			await get_tree().create_timer(0.1).timeout
			DisplayServer.window_set_mode(mode)
		
		SETTING_WINDOW_SIZE:
			if value == 'default':
				get_window().mode = Window.MODE_WINDOWED
				get_window().size = DEFAULT_WINDOW_SIZE
				_current.set_value(section, key, value)
			elif value == 'fullscreen':
				get_window().mode = Window.MODE_FULLSCREEN
				_current.set_value(section, key, value)
			else:
				var arr = value.split('x') as Array
				if arr.size() == 2 and arr[0].is_valid_int() and arr[1].is_valid_int():
					get_window().mode = Window.MODE_WINDOWED
					get_window().size = Vector2(int(arr[0]), int(arr[1]))
					_current.set_value(section, key, value)
				else:
					_current.set_value(section, key, _default[combined_key])
