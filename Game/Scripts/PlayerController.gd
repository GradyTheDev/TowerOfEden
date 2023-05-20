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
@export_range(1, 50) var BASE_DEFENSE: int
@export_range(1, 50) var BASE_HIT_PROBABILITY: int
@export_range(1, 100) var BASE_HIT_POWER: int

@export_subgroup("Melee")
@export_range(0, 200, 0.5) var MELEE_DAMAGE: float
@export_range(0, 50) var MELEE_HIT_PROBABILITY: int
@export_range(0, 100) var MELEE_HIT_POWER: int

@export_subgroup("Ranged")
@export_range(0, 1000, 0.5) var RANGED_DAMAGE: float
@export_range(0, 50) var RANGED_HIT_PROBABILITY: int
@export_range(0, 100) var RANGED_HIT_POWER: int

@export_subgroup("Parry")
@export_range(0, 100) var PARRY_DEF_PROBABILITY: int
@export_range(0, 200) var PARRY_DEF_POWER: int