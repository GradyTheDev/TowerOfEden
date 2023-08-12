class_name AttackBasicProjectile
extends AttackBasic

@export var initial_velocity: Vector2
@export var projectile_gravity: Vector2 = Vector2.DOWN * 50
@export var friction: float = 20
@export var life_span: float = 5
@export var rotate_to_velocity: bool = true
@export var rotate_speed: float = 5

@export_flags_2d_physics var stick_to_body: int
@export var rotate_on_stick: bool = true
@export var disable_on_stick: bool = true
@export var despawn_on_stick: bool = false

@onready var life_timer: float = life_span

var velocity: Vector2
var stuck: bool

func _ready():
	super()
	velocity = initial_velocity
	body_entered.connect(_body_entered)
	global_rotation = velocity.angle()


func _physics_process(delta):
	super(delta)

	life_timer -= delta
	if life_timer <= 0:
		queue_free()

	if stuck: return
	velocity += projectile_gravity * delta
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	global_position += velocity * delta

	global_rotation = lerp(global_rotation, velocity.angle(), rotate_speed * delta)


func _body_entered(body: Node2D):
	var a = TileMap.new()
	if not stuck:
		if body is PhysicsBody2D:
			if body.collision_layer & stick_to_body:
				if stick_to_body:
					stick_to(body)
		else:
			# todo: add proper collision layer bit detection and proper rotation fix
			rotate_on_stick = false # messy workaround
			stick_to(body)


func stick_to(node: Node2D):
	# get out of any signal execution
	await get_tree().process_frame
	if node == null: return
	stuck = true
	velocity = Vector2.ZERO
	var gp = global_position
	var gr = global_rotation
	var p = _pierced
	var s = global_scale
	_pierced = piercing + 1
	get_parent().remove_child(self)
	node.add_child(self)
	global_position = gp
	global_scale = s
	if rotate_on_stick:
		global_rotation = global_position.angle_to_point(node.global_position)
	else:
		global_rotation = gr
	_pierced = p
	if disable_on_stick:
		_pierced = piercing + 1
	if despawn_on_stick:
		queue_free()
