class_name PlayerController extends CharacterBody2D


@export_range(0,1) var decel:float
@export var accel:float
@export var airAccel:float
@export_range(0,1) var moveDecel:float
@export_range(0,1) var airDecel:float
@export var jumpHeight:int
@export var timeToJumpPeak:float
@export var jumpDistance:float
@export var jumpCountMax:int
@export var rollSpeed:float

var selectedAttack:String = ""

var jumpAvailability:bool = true
var gravity:float
var jumpSpeed:float
var maxSpeed:float
var jumpCount:int = jumpCountMax

var rollDirection:float = 0

var in_cutscene: bool = false

@onready var smp: Node = $StateMachinePlayer
@onready var animTree:AnimationTree = $AnimTree
@onready var animController = $AnimTree.get("parameters/playback")
@onready var visuals: Marker2D = $Visuals
@onready var ground_checker: ShapeCast2D = $GroundChecker
@onready var camera: Camera2D = $PlayerCamera
@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var sprite: Sprite2D = $Visuals/Sprite

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
	$PlayerCamera/PlayerUI.size = size
	$PlayerCamera/PlayerUI.position = -size/2

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
			velocity.x = lerp(velocity.x, 0.0, decel)
		"move":
			animController.travel("walk")
			FlipCharacter(GetMoveDirection())
			MoveWithFriction(accel, moveDecel, delta, maxSpeed)
		"jump":
			animController.travel("jump")
			jumpAvailability=false
			jumpCount-=1
			Jump()
		"fall/Entry":
			if coyote_timer.is_stopped():
				coyote_timer.start()
		"fall/coyoteJump":
			jumpCount-=1
			Jump()
		"fall/falling":
			FlipCharacter(velocity.x)
			animController.travel("fall")
			if Input.is_action_just_released("jump") and velocity.y < -jumpSpeed/2:
				velocity.y = -jumpSpeed/2
			MoveWithFriction(airAccel,airDecel, delta, maxSpeed)
			Applygravity(delta)
		"fall/attack":
			animController.travel("attack_forward")
			Applygravity(delta)
		"fall/Exit":
			jumpAvailability = true
			jumpCount = jumpCountMax
		"fall/doubleJump":
			jumpCount-=1
			Jump()
		"attack":
			MoveWithFriction(accel, moveDecel, delta, maxSpeed)
			animController.travel("attack_forward")
		"dodge/Entry":
			health.invincible = true
			rollDirection = GetMoveDirection()
			animController.travel("dodge")
			velocity.x = rollDirection * rollSpeed

func GetMoveDirection()->float:
	if not in_cutscene:
		return Input.get_axis("move_left", "move_right")
	return 0

func GetIsOnFloor()->bool:
	return ground_checker.is_colliding()


func MoveWithFriction(accelS:float, decelS:float, delta:float, maxVel:float)->void:
	var clampVel = clamp(velocity.x, -1, 1)
	var directionVector := Vector2(GetMoveDirection(), 0)
	if GetIsOnFloor():
		var movementRotated := Tools.adjust_vector_to_slope(directionVector, ground_checker.get_collision_normal(0))
		velocity.x += movementRotated.x * accelS
	else:
		velocity.x += GetMoveDirection() * accelS
	if GetMoveDirection() != clampVel:
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
	if Input.is_action_just_pressed("slide") : smp.set_trigger("roll")
	smp.set_param("jumpCount", jumpCount)
	if Input.is_action_just_pressed("attack"): smp.set_trigger("attackPressed")
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
	if not is_inside_tree() or not is_node_ready(): return
	animTree.active = false
	smp.active = false
	anim_player.play("player_animations/death")
	var af = func(a): SavesManager.reload_save.call_deferred()
	anim_player.animation_finished.connect(af,CONNECT_ONE_SHOT)
	pass # Replace with function body.

func _save_start():
	pass

func _on_health_health_changed(old, new) -> void:
	if new < old:
		if sprite == null: return
		var t = sprite.create_tween()
		t.tween_property(sprite, 'modulate', Color.RED, 0.05)
		t.tween_property(sprite, 'modulate', Color.WHITE, 0.05)
		t.play()


func _on_state_machine_player_transited(from, to) -> void:
#	print(from + " to " + to)
	pass # Replace with function body.


func _on_coyote_timer_timeout() -> void:
	jumpAvailability = false
	pass # Replace with function body.


func _on_attack_selector_attempt_made(attempt) -> void:
#	if smp.get_current() == "attack": return
	selectedAttack = attempt
	smp.set_trigger("attackPressed")
	pass # Replace with function body.

func EndAttack()->void:
	smp.set_trigger("endAttack")
	pass

func _on_invinicibility_end() -> void:
	velocity = velocity * .2
	smp.set_trigger("dodgeEnd")
	health.invincible = false
	pass # Replace with function body.
