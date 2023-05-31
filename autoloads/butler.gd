extends Node

const SCENE_MAIN_MENU: String = "res://menus/main_menu/main_menu.tscn"
const SCENE_SETTINGS_MENU: String = "res://menus/settings/settings.tscn"
const SCENE_CREDITS: String = "res://menus/credits/credits.tscn"
const SCENE_LEVEL_SELECT: String = "res://menus/level_select/level_select.tscn"
const SCENE_GAME_OVER: String = "res://menus/game_over/game_over.tscn"

const GROUP_PLAYER: String = "Player"
const GROUP_ENEMY: String = "Enemy"

const SAVE_FILE: String = "user://save.json"
const SETTINGS_FILE: String = "user://settings.json"

@onready var DEFAULT_WINDOW_SIZE := Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
	)

## Emitted before the old scene is queued for deletion
signal changing_scene

## Emitted after the old scene is deleted and
## [br]after the new scene emits [signal Node.ready]
signal scene_changed

## is the game paused
var paused: bool = false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _save_template: Dictionary = {
	"story_progress": 0,
	"money": 0,
	"health": 100,
}

var save: Dictionary = {}


var settings: Dictionary = {
	'debug_controls': false,
	'window_size': 'default' # default, fullscreen, or "width"x"height"
}


func _ready():
	load_settings()
	print()
	load_game()


func _exit_tree():
	save_settings()
	save_game()


func _input(event: InputEvent):
	if event.is_action("toggle_fullscreen") and not event.is_pressed():
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
			await get_tree().process_frame 
			await get_tree().process_frame # wait for the window to change size
			await get_tree().process_frame
			settings.window_size = str(get_window().size.x) + "x" + str(get_window().size.y)
		else:
			get_window().mode = Window.MODE_FULLSCREEN
			settings.window_size = 'fullscreen'


	if settings.debug_controls:
		if event is InputEventKey:
			if event.keycode == KEY_END:
				safe_exit()


## Resets all game data, and then saves the game
## [br]WARNING: Ovewrites the previous save
func new_game():
	save = _save_template.duplicate()
	save_game()


## Doesn't load game data, just starts it
func start_game():
	change_scene_to_file(SCENE_LEVEL_SELECT)


## Exits the game in a safe manner [br]
## Use this instead of using get_tree().quit() directly
func safe_exit():
	get_tree().quit()


## 1. Emits [signal changing_scene] [br]
## 2. waits a frame [br]
## 3. Queue Frees all nodes other than butler [br]
## 4. waits a frame [br]
## 5. Adds the given scene to the scene tree's root node [br]
## 6. Waits for the node to emit it's _ready signal [br]
## 7. Emits [signal scene_changed]
func change_scene_to_packed(scene: PackedScene):
	changing_scene.emit()
	await get_tree().process_frame

	for x in get_tree().root.get_children():
		if x != self:
			x.queue_free()
	await get_tree().process_frame

	var node = scene.instantiate()
	get_tree().root.add_child.call_deferred(node)
	await node.ready

	scene_changed.emit()
	paused = false


## alias for [method change_scene_to_packed]
func change_scene_to_file(path: String):
	var scene = load(path)
	if not (scene is PackedScene and scene.can_instantiate()):
		print("Failed to change to scene ", path, ' ', scene)
		return
	change_scene_to_packed(scene)


func save_settings():
	var json_str := JSON.stringify(settings)
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file == null:
		print_debug('Failed to open settings file\n', FileAccess.get_open_error())
		return
	file.store_string(json_str)


## also applies the settings
func load_settings():
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file == null:
		print_debug('Failed to open settings file\n', FileAccess.get_open_error())
		return
	
	var json_str = file.get_as_text()
	var json := JSON.new()
	var err = json.parse(json_str)
	if err != OK:
		print_debug('Failed to parse json in settings file\n{0}\n{1}'.format(
			[json.get_error_line(), json.get_error_message()]))
		return
	
	if typeof(json.data) != TYPE_DICTIONARY:
		print_debug('Settings file is corrupted!')
		return
	
	for key in settings:
		if json.data.has(key):
			var old_type = typeof(settings[key])
			var new_type = typeof(json.data[key])
			if old_type == new_type or (old_type == TYPE_INT and new_type == TYPE_FLOAT):
				settings[key] = json.data[key]
			else:
				print('value in settings file is the wrong type for key: (', key, ')')
				print('old value: (', settings[key], ')  type: ', old_type)
				print('new value: (', json.data[key], ')  type: ', new_type)
	
	# apply settings
	if settings.window_size == 'default':
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = Butler.DEFAULT_WINDOW_SIZE
		Butler.settings.window_size = 'default'

	elif settings.window_size == 'fullscreen':
		get_window().mode = Window.MODE_FULLSCREEN
		Butler.settings.window_size = 'fullscreen'

	else:
		var arr = settings.window_size.split('x') as Array
		if arr.size() == 2 and arr[0].is_valid_int() and arr[1].is_valid_int():
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Vector2(int(arr[0]), int(arr[1]))


func save_game():
	if save.size() == 0: 
		return # nothing to save
	
	var json_str := JSON.stringify(save)
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		print_debug('Failed to open save file\n', FileAccess.get_open_error())
		return
	file.store_string(json_str)


## Doesn't start the game, just loads the save data from the disk
func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		print_debug('Failed to open save file\n', FileAccess.get_open_error())
		return
	
	var json_str = file.get_as_text()
	var json := JSON.new()
	var err = json.parse(json_str)
	if err != OK:
		print_debug('Failed to parse json in save file\n{0}\n{1}'.format(
			[json.get_error_line(), json.get_error_message()]))
		return
	
	if typeof(json.data) != TYPE_DICTIONARY:
		print_debug('Settings file is corrupted!')
		return
	
	save = _save_template.duplicate()
	for key in save:
		if json.data.has(key):
			var old_type = typeof(save[key])
			var new_type = typeof(json.data[key])
			if old_type == new_type or (old_type == TYPE_INT and new_type == TYPE_FLOAT):
				save[key] = json.data[key]
			else:
				print('value in save file is the wrong type for key: (', key, ')')
				print('old value: (', save[key], ')  type: ', old_type)
				print('new value: (', json.data[key], ')  type: ', new_type)