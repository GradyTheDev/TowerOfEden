class_name Attribute
extends Node

## Attribute
##
## 

@export var body: Node
@export var save: bool = false
var attribute_name: String

func _init(_attribute_name: String):
	attribute_name = _attribute_name


func _enter_tree():
	assert(body is Node, 'Attribute, ERROR: "body" MUST BE ASSIGNED!')
	SavesManager.save_start.connect(_save_start)
	SavesManager.load_start.connect(_load_start)

	body.set_meta(attribute_name, self)

	_load_start()


func _exit_tree():
	_save_start()

	if body.has_meta(attribute_name) and body.get_meta(attribute_name) == self:
		body.set_meta(attribute_name, null)


func _save_start():
	assert(false, "Attribute: Function wasn't overriden by child class!")
	# if not save: return
	# save attributes - see [method save_sub_attribute]


func _load_start():
	assert(false, "Attribute: Function wasn't overriden by child class!")
	# if not save: return
	# load attributes - see [method load_sub_attribute]
	# REMEMBER TO VALIDATE DATA


## CHILD CLASS USAGE ONLY
## saves directly to [SavesManager]
## [br] leave value to null to get(key) instead
func _save_sub_attribute(key: String, value: Variant = null):
	if value == null:
		value = get(key)
	SavesManager.set_value(body.name, key, value)


## CHILD CLASS USAGE ONLY
## doesn't set the local variable, just returns the requested attribute
## type = -1; means to ignore type checking
func _load_sub_attribute(key: String, type: int = -1) -> Variant:
	if not SavesManager.has_key(body.name, key): return null
	
	var v = SavesManager.get_value(body.name, key)
	if type == -1 or typeof(v) == type:
		return v
	return null


## CHILD CLASS USAGE ONLY
## sets the local variable to the given attribute
## if it exists and is of the correct type, else sets it to default
## unless default is of the wrong type (watch ints and float here)
func _smart_load_sub_attribute(key: String, default: Variant = null):
	if not key in self: return
	if not SavesManager.has_key(body.name, key): return

	var atype = typeof(get(key))

	var raw = SavesManager.get_value(body.name, key)
	var rtype = typeof(raw)
	
	if atype == TYPE_INT and rtype == TYPE_FLOAT:
		raw = int(raw)
		rtype = TYPE_INT
	elif atype == TYPE_FLOAT and rtype == TYPE_INT:
		raw = float(raw)
		rtype = TYPE_FLOAT
	
	if atype == rtype:
		set(key, raw)
	else:
		var dtype = typeof(default)

		if atype == TYPE_INT and dtype == TYPE_FLOAT:
			default = int(default)
			dtype = TYPE_INT
		elif atype == TYPE_FLOAT and dtype == TYPE_INT:
			default = float(default)
			dtype = TYPE_FLOAT
		
		if atype == dtype:
			set(key, default)


## use this on a node to get an [Attribute] that's attached to said node
static func get_attribute(body: Node, attribute: String) -> Attribute:
	if not body.has_meta(attribute): return null
	return body.get_meta(attribute)
