extends Node


signal AttemptMade(attempt)
signal actionCleared

var maxTimeTillInput:float = 0.2
var unsolvedActionChain = []
var isInCombo:bool

@export var moveSet:Dictionary
@export var validInputActions:Array[String]

func _input(event: InputEvent) -> void:
	StackInputEvent(event)
	pass

func StackInputEvent(event)->void:
	if !event.is_action_type():
		return
	if event.is_echo():
		return
	if !event.is_pressed():
		return
	
	var action = GetEventAction(event)
	if action:
		unsolvedActionChain.append(action)
		for i in moveSet:
			var arrayMove = moveSet[i]
			##Check if the attempted combo string matches any of the move sets, if so end the function, or else carry on
			if unsolvedActionChain == arrayMove:
				emit_signal("AttemptMade", i)
				break
			else:
				pass
#				print("Failed", unsolvedActionChain, arrayMove)
		##Reset the timer that ends the combo attempt
		$Timer.start(maxTimeTillInput)
	pass
	
func GetEventAction(event)->String:
	var actionName = ""
	var actions = InputMap.get_actions()
	for action in actions:
		if !action in validInputActions:
			continue
		if InputMap.action_has_event(action, event):
			actionName = action
	return actionName

func _on_timer_timeout() -> void:
	unsolvedActionChain.clear()
	pass # Replace with function body.
