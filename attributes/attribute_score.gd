class_name AttributeScore
extends Attribute

## Attribute Score


## emitted when [member score] <= [member score_failure_trigger][br]
## only triggers once (until score goes above failure trigger)
signal on_score_failure()

@export var health: AttributeHealth
@export var attack: AttackBasic

@export var score: float = 20: set = _set_score
@export var score_change_on_being_hit: float = -3
@export var score_change_on_killing_other: float = 10
@export var score_change_per_second: float = -0.1

@export var score_failure_trigger: float = -20

func _init():
	super(Globals.ATTRIBUTE_SCORE)


func _enter_tree():
	health.health_changed.connect(_health_changed)
	attack.delt_damage.connect(_dmg_delt)


func _save_start():
	if not save: return
	_save_sub_attribute("score")


func _load_start():
	if not save: return
	_smart_load_sub_attribute("score", 0)


func _health_changed(old: int, new: int):
	if new < old:
		score += score_change_on_being_hit


func _process(delta: float):
	if Globals.is_in_cutscene:
		return
	
	score += score_change_per_second * delta	

func _dmg_delt(entity: Node, old: int, new: int):
	if old > 0 and new <= 0:
		# just killed enemy
		score += score_change_on_killing_other


func _set_score(v):
	var old = score
	score = v
	Globals.score = score
	if not is_inside_tree(): return
	if old > score_failure_trigger and score <= score_failure_trigger:
		on_score_failure.emit()
		health.health = 0
