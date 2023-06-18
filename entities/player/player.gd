class_name Player
extends Entity

@export var melee_damage: int = 25

@export_group("Physics")
@export var speed: float = 500
@export var max_jumps: int = 2
@export var coyote_time: float = 0.2
@export var jump_buffer_time_limit: float = 0.1
@export var jump_height: float = 300 # pixels
@export var jump_time_to_peak: float = 0.5 # sec 
@export var jump_time_to_floor: float = 0.5 # sec
@export var jump_cancel_velocity_multiplier: float = 0.5

@export_group('Nodes')
@export var camera: Camera2D
@export var hud: Control
@export var pause_menu: Control

@onready var jump_velocity: float =  ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_accend_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
@onready var regular_gravity: float = ((-2.0 * jump_height) / (jump_time_to_floor * jump_time_to_floor)) * -1

## unpaused time, ms
var air_time: float

## unpaused time, ms
## if more than 0, jump is queued
var jump_buffer_timer: float

var jump_counter: int = 0

## buffer after you hit jump to play the jump anim
var jump_anim_fix: float = 0

var money: int = 0

# todo:
# - animation tree: State Machine
# - animations, Idle, Walk, Jump, Attack (directional), injured
# - 

func _ready():
	if Butler.player == null:
		Butler.player = self
	camera.visible = true
	add_to_group(Butler.GROUP_PLAYER)
	super()

	money = Butler.save['money']
	health_max = Butler.save['health_max']
	health = Butler.save['health']

	Butler.saving_game.connect(_saving_game)


func _exit_tree():
	if Butler.player == self:
		Butler.player = null


func _on_death():
	anim_tree.active = false
	anim_player.play("entity_placeholder_animations/death")
	var af = func(a): Butler.change_scene_to_file(Butler.SCENE_LEVEL_SELECT)
	anim_player.animation_finished.connect(af, CONNECT_ONE_SHOT)


func _input(event: InputEvent):
	if Butler.paused or health <= 0: return
	
	if event.is_action("jump") and Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time_limit


func _process(delta):
	pause_menu.visible = Butler.paused

	if Butler.paused or health <= 0: return

	jump_anim_fix = move_toward(jump_anim_fix, 0, delta)
	update_animation_parms()


func _physics_process(delta: float):
	# Smoothly align Camera
	var vrect = min(camera.get_viewport_rect().size.x, camera.get_viewport_rect().size.y)/2
	var weight = remap(camera.global_position.distance_to(global_position), 0, vrect, 0, 1)
	camera.global_position = camera.global_position.lerp(global_position, clamp(weight, 0, 1))
	
	# Pause Menu
	if Butler.paused or health <= 0: return
	
	# Jump Buffer timer
	jump_buffer_timer = move_toward(jump_buffer_timer, 0, delta)

	# Gravity
	velocity.y += get_gravity() * delta
	# velocity.y = move_toward(velocity.y, get_gravity(), get_gravity() * delta)

	if health > 0:
		# Movement
		var input_direction = Vector2(Input.get_axis("move_left", "move_right"), 0)
		if input_direction.x != 0:
			set_direction(input_direction.x >= 0)
	
		if is_on_floor():
			# Movement adjusted to slope of floor
			velocity = Tools.adjust_vector_to_slope(input_direction, get_floor_normal()) * speed

			# var wish = Tools.adjust_vector_to_slope(input_direction, get_floor_normal()) * speed
			# velocity = velocity.move_toward(wish, speed * delta)
		else:
			# Air movement
			velocity.x = input_direction.x * speed
			# var wish = input_direction.x * speed
			# velocity.x = move_toward(velocity.x ,wish, speed * delta)

		# Jump
		# if Input.is_action_just_pressed("jump") and is_on_floor():
		if jump_buffer_timer > 0 and jump_counter < max_jumps and (air_time < coyote_time or jump_counter > 0):
			jump_counter += 1
			jump_buffer_timer = -1
			velocity.y = jump_velocity
			jump_anim_fix = 0.15
			# velocity.y = move_toward(velocity.y, jump_velocity, speed*delta)
		
		if jump_counter > 0 and Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cancel_velocity_multiplier

	# Floor Snap
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and not jump_counter > 0:
		apply_floor_snap()
	
	# Time in Air
	# Jump Counter
	if is_on_floor():
		air_time = 0
		jump_counter = 0
	else:
		air_time += delta

func get_gravity() -> float:
	return jump_accend_gravity if velocity.y < 0 else regular_gravity


func update_animation_parms():
	if health <= 0:
		return

	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = is_on_floor()
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
	anim_tree['parameters/conditions/jump'] = jump_anim_fix > 0
	
	anim_tree['parameters/conditions/attack_forward'] = false
	anim_tree['parameters/conditions/attack_up'] = false
	anim_tree['parameters/conditions/attack_down'] = false
	if Input.is_action_just_pressed("attack"):
		var d = Input.get_vector("move_left", "move_right", "jump", "move_down")
		if is_on_floor():
			if d.y < 0:
				anim_tree['parameters/conditions/attack_up'] = true
			else:
				anim_tree['parameters/conditions/attack_forward'] = true
		else:
			if abs(d.x) > abs(d.y):
				anim_tree['parameters/conditions/attack_forward'] = true
			else:
				if d.y > 0:
					anim_tree['parameters/conditions/attack_down'] = true
				else:
					anim_tree['parameters/conditions/attack_up'] = true

func hurtbox_entered(their_area: Area2D, their_shape: CollisionShape2D, my_shape: CollisionShape2D):
	if their_area is Hitbox and my_shape == $Hurtbox/Attack:
		their_area.entity.hurt(self, melee_damage)

func _saving_game():
	Butler.save['health'] = health
	Butler.save['health_max'] = health_max
	Butler.save['money'] = money