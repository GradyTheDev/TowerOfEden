extends Node
class_name State

var is_active = false

func _ready():
	set_process(false)
	set_physics_process(false)

func _enter(data):
	set_process(true)
	set_physics_process(true)
	is_active = true
	enter(data)

func _exit():
	set_process(false)
	set_physics_process(false)
	is_active = false
	exit()

func enter(data):
	pass

func exit():
	pass
