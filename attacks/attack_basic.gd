class_name AttackBasic
extends Area2D

@export var damage: int = 10

## delay between hitting the same target twice
@export var attack_delay: int = 1

## how many (non unique) targets can be hit before stopping
@export var piercing: int = 999

var _tmp_attack_exceptions: Dictionary

var _pierced: int = 0

var _previous_monitoring_value: bool

func _ready():
	if piercing == INF:
		# piercing is too close to int overflow
		piercing -= 100 
	
	area_exited.connect(_area_exited)
	_previous_monitoring_value = monitoring


func _physics_process(delta):
	if monitoring and not _previous_monitoring_value:
		_pierced = piercing

	_previous_monitoring_value = monitoring

	# Attack delay timers
	for key in _tmp_attack_exceptions:
		_tmp_attack_exceptions[key] -= delta
		if _tmp_attack_exceptions[key] <= 0:
			_tmp_attack_exceptions.erase(key)

	if is_disabled(): return

	# Attack
	var areas := get_overlapping_areas()
	for area in areas:
		if not area is Hitbox or area.health == null: continue
		var id := area.get_instance_id()
		if id in _tmp_attack_exceptions: continue
		area.health.health -= damage
		_tmp_attack_exceptions[id] = attack_delay
		_pierced += 1
		if is_disabled(): return


func _area_exited(area: Area2D):
	if is_disabled(): return
	_tmp_attack_exceptions.erase(area.get_instance_id())


func is_disabled():
	return _pierced > piercing
