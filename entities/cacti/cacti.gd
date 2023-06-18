extends Entity

@export var speed: float = 90

var direction_swith_delay: float = 1
var direction_switch_timer: float = 0

var air_time: float = 0

func _init():
	super()
	add_to_group(Butler.GROUP_ENEMY)

func _physics_process(delta: float):
	if Butler.paused or health <= 0: return
	
	direction_switch_timer -= delta

	velocity.x = speed * get_direction()
	if not is_on_floor():
		velocity.y = 98

	move_and_slide()
	var rv = get_real_velocity().abs()

	if rv.x < 0.01:
		if direction_switch_timer <= 0:
			direction_switch_timer = direction_swith_delay
			flip_direction()
	
	if is_on_floor():
		air_time = 0
	else:
		air_time += delta

	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = air_time < 0.5
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
			
