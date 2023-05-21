extends CharacterBody2D

@export var move_speed_accel = 100.0
@export var move_speed_max = 200.0
@export var move_speed_decel = 50.0

@export_range(0, 500) var jump_height: float
@export_range(0, 5) var jump_time_to_peak: float
@export_range(0, 5) var jump_time_to_descent: float
@export_range(1, 5) var jump_count: int

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var jumpAvailable: bool = true
var jumpCounter: int = 0

func _process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * move_speed_max

	if Input.is_action_just_pressed("jump") and jumpAvailable:
		velocity.y = jump_velocity
		if jumpCounter == jump_count - 1:
			$JumpVFX.emitting = true
		jumpCounter += 1
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		$JumpVFX.emitting = false
		velocity.y /= 2


	move_and_slide()

func _physics_process(_delta):
	if jumpCounter >= jump_count: # Disable jump if all jumps are depleted
		jumpAvailable = false

	if is_on_floor(): # Reset jump on floor hit
		jumpAvailable = true
		jumpCounter = 0

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func get_input_velocity():
	var horizontal := 0.0
	
	if Input.is_action_pressed("move_left"):
		horizontal -= move_speed_accel
	if Input.is_action_pressed("move_right"):
		horizontal += move_speed_accel
	
	return horizontal
