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

## -1 = left [br]
## 1 = right
## type float, see game controller analog input
var facing_direction: int

@export var health: int = 100 : set = _set_health
@export var damage: int = 25


func _ready():
	health = Butler.save.get('health', 100)
	set_facing_direction(1)
	$CameraFix.visible = true


func _process(delta):
	if Butler.paused:
		return
	
	var direction = Input.get_axis("move_left", "move_right")
	set_facing_direction(direction)

	velocity.y += get_gravity() * delta
	velocity.x = direction * move_speed_max

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
	if Butler.paused:
		return
	
	if jumpCounter >= jump_count: # Disable jump if all jumps are depleted
		jumpAvailable = false

	if is_on_floor(): # Reset jump on floor hit
		jumpAvailable = true
		jumpCounter = 0


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


# todo: ESC btn opens/closes pause menu 
func _input(event: InputEvent):
	# Actions in pause menu
	if event.is_action("pause") and not event.is_pressed():
		Butler.paused = not Butler.paused
	
	if Butler.paused:
		return

	# Actions in game
	if event.is_action("attack") and not event.is_pressed():
		if facing_direction == 1:
			$AnimationPlayer.play("right_attack")
		else:
			$AnimationPlayer.play("left_attack")


## negitive = left [br]
## positive = right [br]
## see [member facing_direction]
func set_facing_direction(direction: float):
	# this deals with joysticks which give decimal output
	if direction > 0:
		direction = 1
	elif direction < 0:
		direction = -1

	if direction == facing_direction:
		return

	if direction > 0:
		$AnimationPlayer.play("right_idle")
		facing_direction = 1
	elif direction < 0:
		$AnimationPlayer.play("left_idle")
		facing_direction = -1


func _on_hurt_box_area_entered(area: Area2D):
	var target = area.get_parent()
	if Butler.GROUP_ENEMY in target.get_groups():
		assert(target.get('health') is int, 'Missing "health" variable in this node -> ' + target.name + ":" + target.get_class())
		if target.health > 0:
			target.health -= damage
			if OS.is_debug_build():
				print(name, ' hit ', target.name, ' hp: ', target.health)


func _set_health(v: int):
	health = v
	Butler.save.health = health
	if health <= 0:
		Butler.load_game()
		Butler.change_scene_to_file(Butler.SCENE_GAME_OVER)