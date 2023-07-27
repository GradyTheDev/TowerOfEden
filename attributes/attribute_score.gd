class_name AttributeScore
extends Attribute

## Attribute Score
##
## You'll have to manually add [member score_change_on_killing_other] to score

## emitted when [member score] <= [member score_failure_trigger][br]
## only triggers once (until score goes above failure trigger)
signal on_score_failure()

@export var health: AttributeHealth

@export var score: float = 20
@export var score_change_on_being_hit: float = -3
@export var score_change_on_killing_other: float = 10
@export var score_change_per_second: float = -0.1

@export var score_failure_trigger: float = -20

func _init():
	super(Globals.ATTRIBUTE_SCORE)
	await get_tree().create_timer(0.3)
	health.health_changed.connect(_health_changed)


func _save_start():
	if not save: return
	_save_sub_attribute("score")


func _load_start():
	if not save: return
	_smart_load_sub_attribute("score", 0)


func _health_changed(old: int, new: int):
	if old < new:
		score += score_change_on_being_hit


func _process(delta: float):
	var old = score
	score += score_change_per_second * delta

	if old < score_failure_trigger and score >= score_failure_trigger:
		on_score_failure.emit()
