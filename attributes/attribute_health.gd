class_name AttributeHealth
extends Attribute

signal death()

signal revived()

## fired when health changes
signal health_changed(old: int, new: int)

@export var health: int = 100: set = _set_health
@export var health_max: int = 100: set = _set_health_max

## Prevents you from taking damge. Can heal.
## [br]unless [member health_max] changes to a lower than health value
@export var invincible: bool

## READONLY
var alive: bool

func _init():
	super(Globals.ATTRIBUTE_HEALTH)

	var h = health
	_set_health_max(health_max)
	_set_health(h)


func _set_health(new: int):
	new = clamp(new, 0, health_max)
	if new == health:
		alive = health > 0
		return
	
	var old = health
	if new < old and invincible:
		return

	health = new
	alive = health > 0

	health_changed.emit(old, health)
	if old > 0 and new <= 0:
		death.emit()
	elif old <= 0 and new > 0:
		revived.emit()


func _set_health_max(new: int):
	if new == health_max: return
	health_max = new
	_set_health(clamp(health, 0, health_max))


func _save_start():
	if not save: return
	SavesManager.set_value(body.name, 'health_max', health_max)
	SavesManager.set_value(body.name, 'health', health)


func _load_start():
	if not save: return
	var raw = SavesManager.get_value(body.name, 'health_max', null)
	if typeof(raw) == TYPE_INT:
		health_max = raw

	raw = SavesManager.get_value(body.name, 'health', null)
	if typeof(raw) == TYPE_INT:
		health = raw
