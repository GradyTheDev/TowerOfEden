extends Node
class_name StateMachine

enum STATE {WALK, IDLE, ATTACK, MOVEBACKWARD, DEATH}
@export var initial_state: STATE = STATE.IDLE
var all_states: Dictionary
var current_state: State
@onready var debug_state = $"%State"



func _ready():
	load_children()
	current_state = all_states[initial_state]
	current_state._enter({})
	debug_state.text = current_state.name


func load_children():
	var _states = self.get_children()
	for state in _states:
		var enum_state = STATE[state.get_name().to_upper()]
		all_states[enum_state] = state


func change_state_to(new_state, data):
	assert(all_states.has(new_state), "There is no" + str(new_state) + "state in all_states")
	current_state._exit()
	current_state = all_states[new_state]
	debug_state.text = current_state.name
	current_state._enter(data)
