extends Entity

@export var damage: int = 25
@export var attack_delay: float = 1
@export var aggro_range: int = 1000
@export var speed: int = 150
@export var gravity: float = 98
@export_flags_2d_physics var sight_mask: int
@export var arrow_speed: float = 500

@onready var bowr: Node2D = $bow_rotate

@onready var pck_arrow: PackedScene = preload("res://entities/bandit/arrow.tscn")

var _sight_delay: float = 0.2  # sec
var _sight_timer: float = 0  # sec

var _can_hit: bool = false
var _attack_timer: float = 0
var air_time: float = 0

enum states{
	idle,
	hunting
}

var state: states = states.idle

func _ready():
	super()
	add_to_group(Butler.GROUP_ENEMY)


func _physics_process(delta):
	if Butler.paused or health <= 0: return

	if _sight_timer > 0:
		_sight_timer -= delta
	else:
		refresh_sight()
	
	_attack_timer = move_toward(_attack_timer, 0, delta)
	
	if Butler.player == null or Butler.player.health <= 0 and state == states.hunting:
		state = states.idle

	if state == states.idle:
		bowr.rotation_degrees = 0
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	elif state == states.hunting:
		var dis := global_position.distance_to(Butler.player.global_position)
		var dir := global_position.direction_to(Butler.player.global_position)
		bowr.look_at(Butler.player.global_position)
		if dis > aggro_range / 2:
			velocity = dir * speed
		elif dis < aggro_range / 3:
			velocity = dir * -speed
		else:
			velocity = Vector2.ZERO

		if Butler.player.global_position.x >= global_position.x:
			set_direction(true)
		else:
			set_direction(false)
		
		if _can_hit and _attack_timer <= 0:
			shoot()

	if not is_on_floor():
		velocity.y = gravity

	move_and_slide()
	if is_on_floor():
		air_time = 0
	else:
		air_time += delta
	update_animation_parms()


func refresh_sight():
	_sight_timer = _sight_delay
	if Butler.player != null and Butler.player.health > 0:
		var player = Butler.player as Player
		var dis := global_position.distance_to(player.global_position)
		
		if dis < aggro_range:
			var space := get_world_2d().direct_space_state
		
			var query := PhysicsRayQueryParameters2D.create(
				global_position,
				Butler.player.global_position,
				sight_mask
			)

			var dict := space.intersect_ray(query)
			var collider = dict.get('collider')
			if collider is Player:
				state = states.hunting
				_can_hit = dis < aggro_range
			else:
				state = states.idle
		else:
			state = states.idle


func _on_hurtbox_area_entered(area: Area2D):
	if area is Hitbox and area.target is Player:
		area.target.health -= damage


func update_animation_parms():
	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = air_time < 0.5
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
	# anim_tree['parameters/conditions/jump'] = jump_anim_fix > 0
	
	anim_tree['parameters/conditions/attack_forward'] = false
	anim_tree['parameters/conditions/attack_up'] = false
	anim_tree['parameters/conditions/attack_down'] = false


func shoot():
	_attack_timer = attack_delay
	var arrow = pck_arrow.instantiate() as Entity

	var dis = global_position.distance_to(Butler.player.global_position)
	var dir = global_position.direction_to(Butler.player.global_position)
	arrow.position = global_position + dir * 150
	arrow.init_velocity = dir * arrow_speed
	arrow.target = Butler.player

	get_tree().root.add_child(arrow)
