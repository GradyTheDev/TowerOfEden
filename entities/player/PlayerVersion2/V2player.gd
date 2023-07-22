class_name PlayerController extends CharacterBody2D


@export_range(0,1) var decel:float
@export var accel:float
@export var airAccel:float
@export_range(0,1) var moveDecel:float
@export_range(0,1) var airDecel:float
@export var jumpHeight:int
@export var timeToJumpPeak:float
@export var jumpDistance:float

var jumpAvailability:bool = true
var gravity:float
var jumpSpeed:float
var maxSpeed:float

var in_cutscene: bool = false

@onready var smp: Node = $StateMachinePlayer
@onready var animController = $AnimTree.get("parameters/playback")
@onready var visuals: Marker2D = $Visuals
@onready var ground_checker: ShapeCast2D = $GroundChecker
@onready var camera: Camera2D = $PlayerCamera
@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var coyote_timer: Timer = $CoyoteTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var MaxGravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _init():
	add_to_group(Globals.GROUP_PLAYER)

func _exit_tree():
	if Globals.player == self:
		Globals.player = null
	if health.alive:
		_save_start()

func _ready() -> void:
	SetJumpSpeed()
	SetGlobalsAndCamera()
	pass

func SetGlobalsAndCamera()->void:
	if Globals.player == null:
		Globals.player = self
	
	camera.visible = true

	# resize ui elements to camera size and zoom
	var size = camera.get_viewport_rect().size / camera.zoom
#	$Camera/PlayerUI.size = size
#	$Camera/PlayerUI.position = -size/2

	SavesManager.save_start.connect(_save_start)

	$AnimTree.active = true

	# todo: snap to floor

	# snap camera to player
	camera.global_position = global_position
	

func _process(delta: float) -> void:
	HandleStateTransitions()
	pass

func _physics_process(delta: float) -> void:
	StateMachineDelta(delta)
	move_and_slide()


func StateMachineDelta(delta:float)->void:
	#State machine
	match smp.get_current():
		"idle":
			animController.travel("idle")
			jumpAvailability = true
			velocity.x = lerp(velocity.x, 0.0, decel)
		"move":
			animController.travel("walk")
			FlipCharacter(GetMoveDirection())
			jumpAvailability = true
			MoveWithFriction(accel, moveDecel, delta, maxSpeed)
		"jump":
			animController.travel("jump")
			jumpAvailability=false
			Jump()
		"fall/Entry":
			if coyote_timer.is_stopped():
				coyote_timer.start()
		"fall/coyoteJump":
			Jump()
		"fall/falling":
			FlipCharacter(GetMoveDirection())
			animController.travel("fall")
			if Input.is_action_just_released("jump") and velocity.y < -jumpSpeed/2:
				velocity.y = -jumpSpeed/2
#			MoveWithFriction(airAccel,airDecel, delta, maxSpeed)
			Applygravity(delta)
		"attack":
			pass
	pass

func GetMoveDirection()->float:
	if health.alive and not in_cutscene:
		return Input.get_axis("move_left", "move_right")
	return 0

func GetIsOnFloor()->bool:
	return is_on_floor()


func MoveWithFriction(accelS:float, decelS:float, delta:float, maxVel:float)->void:
	var clampVel = clamp(velocity.x, -1, 1)
	var directionVector := Vector2(GetMoveDirection(), 0)
	var movementRotated := Tools.adjust_vector_to_slope(directionVector, ground_checker.get_collision_normal(0))
	velocity.x += movementRotated.x * accelS * delta
	if GetMoveDirection() != clampVel and GetMoveDirection() != 0:
		velocity.x *= decelS
#	else:
#		velocity.x += moveDir.x * accelS * delta
#		if moveDir.x != clampVel:
#			velocity.x *= decelS
	velocity.x = clamp(velocity.x, -maxVel, maxVel)

func Applygravity(delta:float)->void:
	if velocity.y>=gravity:
		velocity.y = gravity
	else:
		velocity.y+= gravity *delta

func Jump()->void:
	velocity.y = -jumpSpeed

func HandleStateTransitions()->void:
	#Handling all the data that the state machine needs
	smp.set_param("onFloor", GetIsOnFloor())
	smp.set_param("movement", GetMoveDirection())
	if Input.is_action_just_pressed("jump") : smp.set_trigger("jump")
	smp.set_param("coyoteAvailable", jumpAvailability)
	pass

func SetJumpSpeed()->void:
	gravity = (2*jumpHeight) / pow(timeToJumpPeak,2)
	jumpSpeed = gravity * timeToJumpPeak
	maxSpeed = jumpDistance / (2*timeToJumpPeak)

func FlipCharacter(dir):
	if dir>0:
		visuals.scale.x = 1
	elif dir<0:
		visuals.scale.x = -1

func _on_health_death() -> void:
	pass # Replace with function body.

func _save_start():
	pass

func _on_health_health_changed(old, new) -> void:
	pass # Replace with function body.


func _on_state_machine_player_transited(from, to) -> void:
#	print(from + " to " + to)
	pass # Replace with function body.


func _on_coyote_timer_timeout() -> void:
	jumpAvailability = false
	pass # Replace with function body.


func _on_attack_selector_attempt_made(attempt) -> void:
	print(attempt)
	pass # Replace with function body.
