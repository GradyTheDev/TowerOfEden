class_name Player
extends CharacterBody2D

@export var dialog_text: String:
	set(new_text):
		dialog_text = new_text
		if dialog != null:
			dialog.set_text(new_text)

@export_group("Physics")
@export var speed: float = 500
@export var max_jumps: int = 2
@export var coyote_time: float = 0.2
@export var jump_buffer_time_limit: float = 0.1
@export var jump_height: float = 200 # pixels
@export var jump_time_to_peak: float = 0.5 # sec
@export var jump_time_to_floor: float = 0.5 # sec
@export var jump_cancel_velocity_multiplier: float = 0.5


@onready var jump_velocity: float =  ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_accend_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
@onready var regular_gravity: float = ((-2.0 * jump_height) / (jump_time_to_floor * jump_time_to_floor)) * -1


@onready var camera: Camera2D = get_node("Camera")
@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
var camera_follow_player: bool = true

@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var sprite: Sprite2D = get_node("Visuals/Sprite")
@onready var dialog: RichTextLabel = get_node("Dialog")

## unpaused time, ms
var air_time: float

## unpaused time, ms
## if more than 0, jump is queued
var jump_buffer_timer: float

var jump_counter: int = 0

## buffer after you hit jump to play the jump anim
var jump_anim_fix: float = 0

# var money: int = 0

var in_cutscene: bool = false

func _init():
	add_to_group(Globals.GROUP_PLAYER)


func _ready():
	self.dialog_text = self.dialog_text

	if Globals.player == null:
		Globals.player = self
	
	camera.visible = true

	# resize ui elements to camera size and zoom
	var size = camera.get_viewport_rect().size / camera.zoom
	$Camera/PlayerUI.size = size
	$Camera/PlayerUI.position = -size/2

	SavesManager.save_start.connect(_save_start)

	anim_tree.active = true

	# todo: snap to floor

	# snap camera to player
	camera.global_position = global_position


func _exit_tree():
	if Globals.player == self:
		Globals.player = null
	if health.alive:
		_save_start()


func _on_death():
	if not is_inside_tree() or not is_node_ready(): return
	anim_tree.active = false
	anim_player.play("player_animations/death")
	var af = func(a): SavesManager.reload_save.call_deferred()
	anim_player.animation_finished.connect(af,CONNECT_ONE_SHOT)
	# health.save = false


func _input(event: InputEvent):
	if not health.alive or in_cutscene: return
	if event.is_action("jump") and Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time_limit


func _physics_process(delta: float):
	if camera_follow_player:
		# Smoothly align Camera
		var vrect = min(camera.get_viewport_rect().size.x, camera.get_viewport_rect().size.y)/2
		var weight = remap(camera.global_position.distance_to(global_position), 0, vrect, 0, 1)
		camera.global_position = camera.global_position.lerp(global_position, clamp(weight, 0, 1))
	
	# Jump anim fix (fix jump anim switching spam)
	jump_anim_fix = move_toward(jump_anim_fix, 0, delta)

	# Jump Buffer timer
	jump_buffer_timer = move_toward(jump_buffer_timer, 0, delta)

	# cutscene - disable physics
	if in_cutscene and is_on_floor():
		return

	# Gravity
	var gravity = get_gravity()
	if velocity.y < gravity and not is_on_floor():
		velocity.y += gravity * delta

	if health.alive and not in_cutscene:
		# Movement
		var input_direction = Vector2(Input.get_axis("move_left", "move_right"), 0)
		if input_direction.x != 0:
			Tools.set_node2D_direction(self, input_direction.x > 0)
	
		if is_on_floor():
			# Movement adjusted to slope of floor
			velocity = Tools.adjust_vector_to_slope(input_direction, get_floor_normal()) * speed
		else:
			# Air movement
			velocity.x = input_direction.x * speed

		# Jump
		if jump_buffer_timer > 0 and jump_counter < max_jumps and (air_time < coyote_time or jump_counter > 0):
			jump_counter += 1
			jump_buffer_timer = -1
			velocity.y = jump_velocity
			jump_anim_fix = 0.15
			# velocity.y = move_toward(velocity.y, jump_velocity, speed*delta)
		
		if jump_counter > 0 and Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cancel_velocity_multiplier
	
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 1300 * delta)

	# Floor Snap
	var was_on_floor = is_on_floor()
	move_and_slide()
	update_animation_parms()
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
	if not health.alive: return

	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = is_on_floor()
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
	anim_tree['parameters/conditions/jump'] = jump_anim_fix > 0
	
	anim_tree['parameters/conditions/attack_forward'] = false
	anim_tree['parameters/conditions/attack_up'] = false
	anim_tree['parameters/conditions/attack_down'] = false
	if Input.is_action_just_pressed("attack") and not in_cutscene:
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


func _save_start():
	pass



func _on_health_changed(old: int, new: int):
	if new < old:
		if sprite == null: return
		var t = sprite.create_tween()
		t.tween_property(sprite, 'modulate', Color.RED, 0.05)
		t.tween_property(sprite, 'modulate', Color.WHITE, 0.05)
		t.play()
