extends CharacterBody2D

@export var health: int = 100 : set = _set_health
@export var damage: int = 10
@export var speed: int = 100

## in seconds
@export var damage_delay: float = 0.1
## in seconds
@export var switch_direction_delay: float = 0.5

@onready var hurtbox: Area2D = $Hurtbox

var moving_right: bool = false

var _damage_delay_countdown: float = 0
var _switch_direction_delay_countdown: float = 0

func _physics_process(delta: float):
	if Butler.paused:
		return
	
	if _switch_direction_delay_countdown > 0:
		_switch_direction_delay_countdown -= delta

	if moving_right:
		$Sprite.flip_h = false
		velocity = Vector2.RIGHT * speed
		velocity.y += 35
		var gpos = global_position
		move_and_slide()

		if gpos.distance_to(global_position) < 0.5:
			if _switch_direction_delay_countdown <= 0:
				moving_right = false
				_switch_direction_delay_countdown = switch_direction_delay
	else:
		$Sprite.flip_h = true
		velocity = Vector2.LEFT * speed
		velocity.y += 35
		var gpos = global_position
		move_and_slide()

		if gpos.distance_to(global_position) < 0.5:
			if _switch_direction_delay_countdown <= 0:
				moving_right = true
				_switch_direction_delay_countdown = switch_direction_delay
	
	if _damage_delay_countdown > 0:
		_damage_delay_countdown -= delta
	else:
		for a in hurtbox.get_overlapping_areas():
			overlap(a)


func _set_health(v: int):
	if v < health:
		var tween = create_tween()
		tween.tween_property($Sprite, 'self_modulate', Color.RED, .05)
		tween.tween_property($Sprite, 'self_modulate', Color.WHITE, .05)
		tween.play()
	
	health = v
	if health <= 0:
		Butler.save.money += 10
		queue_free()


func _on_hurtbox_area_entered(area:Area2D):
	overlap(area)


func overlap(area: Area2D):
	if _damage_delay_countdown > 0: return
	
	var target = area.get_parent()
	if Butler.GROUP_PLAYER in target.get_groups():
		assert(target.get('health') is int, 'Missing "health" variable in this node -> ' + target.name + ":" + target.get_class())
		if target.health > 0:
			target.health -= damage
			_damage_delay_countdown = damage_delay
			if OS.is_debug_build():
				print(name, ' hit ', target.name, ' hp: ', target.health)