extends CharacterBody2D

@export var move_speed = 200.0

@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var jumpAvailable: bool = true

func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * move_speed
	
	if is_on_floor():
		jumpAvailable = true
	if Input.is_action_just_pressed("jump") and jumpAvailable:
		velocity.y = jump_velocity
		jumpAvailable = false
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y /= 2


	move_and_slide()

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func get_input_velocity():
	var horizontal := 0.0
	
	if Input.is_action_pressed("move_left"):
		horizontal -= 1.0
	if Input.is_action_pressed("move_right"):
		horizontal += 1.0
	
	return horizontal
