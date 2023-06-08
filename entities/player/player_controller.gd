extends CharacterBody2D
class_name PlayerController

@export_category("Player Controller")

@export_group("Movement")
@export_range(0, 100, 0.5) var WEIGHT: float
@export_range(0, 200, 0.5) var SKIDDING: float

@export_subgroup("Run")
@export_range(0, 750, 2.5) var RUN_ACCEL: float
@export_range(0, 750, 2.5) var RUN_MAX: float
@export_range(0, 750, 2.5) var RUN_DECEL: float

@export_subgroup("Jump")
@export_range(0, 500, 2.5) var JUMP_CLIMB: float
@export_range(0, 500, 2.5) var JUMP_HANG: float
@export_range(0, 500, 2.5) var JUMP_FALL: float
@export_range(1, 5) var JUMP_COUNT: int

@export_group("Combat")
@export_range(1, 10) var BASE_HEALTH: int
@export_range(1, 100) var BASE_DAMAGE: int
@export_range(0, 5, 0.2) var BASE_ATK_COOLDOWN: float
@export_range(1, 50) var BASE_DEFENSE: int
@export_range(1, 100) var BASE_DEF_POWER: int
@export_range(1, 100) var BASE_ATK_POWER: int

@export_subgroup("Melee")
@export_range(0, 200, 0.5) var MELEE_DAMAGE: float
@export_range(0, 100) var MELEE_ATK_POWER: int

@export_subgroup("Ranged")
@export_range(0, 1000, 0.5) var RANGED_DAMAGE: float
@export_range(0, 100) var RANGED_ATK_POWER: int

@export_subgroup("Parry")
@export_range(0, 200) var PARRY_DEF_POWER: int
@export_range(0, 100) var PARRY_REFLECTED_DMG_PERCENT: int

enum MoveType {
	IDLE, # Idle
	ACCEL, # Accelerating
	MAX, # Maximum speed reached
	DECEL # Decelerating
}

enum Direction {
	IDLE, # Idle
	LEFT, # Moving left
	RIGHT # Moving right
}

@onready var moveState := [MoveType.IDLE, Direction.IDLE]

func _process(delta):
	velocity.y += 5 if velocity.y < 0 else 10

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		performRunFrame(delta)
	print(position)

func performRunFrame(delta: float):
	var isMoveActionPressed := Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	var hasReachedMaxSpeed := velocity.x <= -RUN_MAX or velocity.x >= RUN_MAX

	moveState[1] = Direction.LEFT if velocity.x < -1 else Direction.RIGHT if velocity.x > 1 else Direction.IDLE
	moveState[0] = MoveType.IDLE if not isMoveActionPressed and moveState[1] == Direction.IDLE else moveState[0]
	moveState[0] = MoveType.ACCEL if isMoveActionPressed and moveState[1] != Direction.IDLE and not hasReachedMaxSpeed else moveState[0]
	moveState[0] = MoveType.MAX if isMoveActionPressed and moveState[1] != Direction.IDLE and hasReachedMaxSpeed else moveState[0]
	moveState[0] = MoveType.DECEL if not isMoveActionPressed and moveState[1] != Direction.IDLE and not hasReachedMaxSpeed else moveState[0]

	if moveState[1] == Direction.RIGHT:
		match moveState[0]:
			MoveType.IDLE: velocity.x = 0
			MoveType.ACCEL: velocity.x += RUN_ACCEL * delta
			MoveType.MAX: velocity.x = RUN_MAX
			MoveType.DECEL: velocity.x -= RUN_DECEL * delta
	elif moveState[1] == Direction.LEFT:
		match moveState[0]:
			MoveType.IDLE: velocity.x = 0
			MoveType.ACCEL: velocity.x -= RUN_ACCEL * delta
			MoveType.MAX: velocity.x = -RUN_MAX
			MoveType.DECEL: velocity.x += RUN_DECEL * delta
	else:
		velocity.x = 0
	move_and_slide()
