extends EditorInspectorPlugin

const YAFSM_State = preload("res://addons/imjp94.yafsm/src/states/State.gd")

func _can_handle(object):
	return object is YAFSM_State

func _parse_property(object, type, path, hint, hint_text, usage, wide) -> bool:
	return false
	# Hide all property
	return true
