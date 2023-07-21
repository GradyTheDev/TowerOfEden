@tool
class_name Portal
extends Area2D

## Portal
##
## Node name must have the prefix "portal_" see [AttributePortalTransversal]
## any [Portal] must have the prefix "portal_"

signal teleporting(entity: Node2D)

@export var enabled: bool = true

## saves the state of [member enabled] to the save file
@export var save: bool = false

## this is the (name of the) portal where the entity should teleport to, when they load into the next scene
## [br]without the "portal_" prefix
@export_placeholder('w/o "portal_" prefix') var to_portal: String = ''

@export var exit_pos: Node2D

@export var timeout_delay: float = 1

var scene: int
var _editor_scene_keys := []
var _editor_scene_values := []

var _timeout: float = 0

func _init():
	if Engine.is_editor_hint(): return
	body_entered.connect(_body_entered)


func _process(delta):
	_timeout = move_toward(_timeout, 0, delta)


func _enter_tree():
	_editor_scene_keys = ['level select', 'debug level']
	_editor_scene_values = [Globals.SCENE_LEVEL_SELECT, Globals.SCENE_DEBUG_LEVEL]
	_editor_scene_keys.append_array(Globals.LEVELS.keys())
	_editor_scene_values.append_array(Globals.LEVELS.values())

	if Engine.is_editor_hint():return

	add_to_group(Globals.GROUP_PORTAL)
	
	SavesManager.save_start.connect(_save_start)
	SavesManager.load_start.connect(_load_start)
	if save: _load_start()


func _exit_tree():
	if Engine.is_editor_hint(): return
	if save: _save_start()


func _get(property: StringName):
	match property:
		"scene":
			return scene
	
	return null # handle normally


func _set(property: StringName, value: Variant):
	match property:
		"scene":
			scene = value
			return true
	
	return false # handle normally


func _get_property_list():
	var properties = []
	properties.append({
		"name": "scene",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ','.join(_editor_scene_keys),
	})

	return properties


func _body_entered(body: Node2D):
	if Engine.is_editor_hint(): return
	if not enabled: return
	if exit_pos == null: return
	if _timeout > 0: return

	var pta = Attribute.get_attribute(body, Globals.ATTRIBUTE_PORTAL_TRANSVERSAL)
	if pta == null: return
	_timeout = timeout_delay
	pta.last_portal = name
	pta.to_portal = to_portal

	# attempt to teleport.
	teleporting.emit(body)
	pta.teleport()


func _save_start():
	if Engine.is_editor_hint(): return
	if not save: return
	SavesManager.set_value('portals', name, enabled)


func _load_start():
	if Engine.is_editor_hint(): return
	if not save: return
	var raw = SavesManager.get_value('portals', name)
	if typeof(raw) == TYPE_BOOL:
		enabled = raw


func get_scene_path() -> String:
	return _editor_scene_values[scene]
