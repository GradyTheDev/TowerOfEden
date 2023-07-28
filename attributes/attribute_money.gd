class_name AttributeMoney
extends Attribute

@export var money: int = 0


func _init():
	super(Globals.ATTRIBUTE_MONEY)


func _save_start():
	if not save: return
	_save_sub_attribute("money")


func _load_start():
	if not save: return
	_smart_load_sub_attribute("money", 0)
