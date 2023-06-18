extends Entity

@export var init_velocity: Vector2
@export var friction: float = 10
@export var gravity: float = 98
@export var fall_accel: float = 30

@export var target: Node2D
@export var homing_power: float = 500
@export var homing_range: float = 300
@export var life_time: float = 5

var stuck: bool = false

func _ready():
	velocity = init_velocity
	# look_at(global_position + init_velocity)
	rotation = init_velocity.angle()


func _physics_process(delta: float):
	if Butler.paused or health <= 0 or is_queued_for_deletion(): return
	
	life_time -= delta
	if life_time <= 0:
		queue_free()

	if stuck: return

	if target != null:
		var dis = global_position.distance_to(target.global_position)
		var dir = global_position.direction_to(target.global_position)
		var angle = global_position.angle_to(target.global_position)
		if  dis < homing_range: 
			velocity += dir * homing_power * delta

	velocity.x = move_toward(velocity.x, 0, friction * delta)
	velocity.y = move_toward(velocity.y, gravity, fall_accel * delta)

	var c = move_and_collide(velocity * delta)
	if c != null:
		target = null
		if c.get_collider() is TileMap:
			stuck = true
			collide_damage = 0
		else:
			queue_free()
	
	rotation = lerp(rotation, velocity.angle(), 0.1)


func _on_death():
	queue_free()


func hurtbox_entered(their_area: Area2D, their_shape: CollisionShape2D, my_shape: CollisionShape2D):
	queue_free()
