extends CharacterBody2D


@export var far: int = 500
@export var near: int = 300
@export var passive: bool = false

@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var sprite: Sprite2D = get_node("Sprite")
@onready var audio_walk = get_node("walk") as AudioStreamPlayer2D
@onready var audio_attack = get_node("attack") as AudioStreamPlayer2D


func _ready():
	health.death.connect(_on_death)
	health.health_changed.connect(_on_health_changed)
	add_to_group(Globals.GROUP_ENEMY)
	anim_tree.active = true


func _on_death():
	if not is_inside_tree() or not is_node_ready(): return
	anim_tree.active = false
	anim_player.play("bow_bandit_animations/death")
	var af = func(a): queue_free()
	anim_player.animation_finished.connect(af, CONNECT_ONE_SHOT)


func _on_health_changed(old: int, new: int):
	if new < old:
		var t = sprite.create_tween()
		t.tween_property(sprite, 'modulate', Color.RED, 0.05)
		t.tween_property(sprite, 'modulate', Color.WHITE, 0.05)
		t.play()

#########

@export var damage: int = 25
@export var attack_delay: float = 1
@export var aggro_range: int = 1000
@export var speed: int = 150
@export var gravity: float = 98
@export_flags_2d_physics var sight_mask: int
@export var arrow_speed: float = 500

# @onready var bowr: Node2D = $bow_rotate

@export var pck_arrow: PackedScene

var _sight_delay: float = 0.2  # sec
var _sight_timer: float = 0  # sec

var _can_hit: bool = false
var _attack_timer: float = 0
var air_time: float = 0

enum states{
	idle,
	hunting
}

var state: states = states.idle


func _physics_process(delta):
	if not health.alive: return

	if _sight_timer > 0:
		_sight_timer -= delta
	else:
		refresh_sight()
	
	_attack_timer = move_toward(_attack_timer, 0, delta)
	
	if passive or Globals.player == null or not Globals.player.health.alive and state == states.hunting:
		state = states.idle

	if state == states.idle:
		# bowr.rotation_degrees = 0
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	elif state == states.hunting:
		var dis := global_position.distance_to(Globals.player.global_position)
		var dir := global_position.direction_to(Globals.player.global_position)
		# bowr.look_at(Globals.player.global_position)

		if dis > far:
			velocity = dir * speed
		elif dis < near:
			velocity = dir * -speed
		else:
			velocity = Vector2.ZERO

		Tools.set_node2D_direction(self, Globals.player.global_position.x <= global_position.x)
		
		if velocity.x == 0 and _can_hit and _attack_timer <= 0 and anim_player.current_animation != 'bow_bandit_animations/attack_forward':
			anim_player.play("bow_bandit_animations/attack_forward")
			anim_tree.active = false
			# shoot()

	if not is_on_floor():
		velocity.y = gravity

	move_and_slide()
	if is_on_floor():
		air_time = 0
	else:
		air_time += delta
	update_animation_parms()


func refresh_sight():
	_sight_timer = _sight_delay
	if Globals.player != null and Globals.player.health.alive:
		var player = Globals.player as PlayerController
		var dis := global_position.distance_to(player.global_position)
		
		if dis < aggro_range:
			var space := get_world_2d().direct_space_state
		
			var query := PhysicsRayQueryParameters2D.create(
				global_position,
				Globals.player.global_position,
				sight_mask
			)

			var dict := space.intersect_ray(query)
			var collider = dict.get('collider')
			if collider is PlayerController:
				state = states.hunting
				_can_hit = dis < aggro_range
			else:
				state = states.idle
		else:
			state = states.idle


func _on_hurtbox_area_entered(area: Area2D):
	if passive: return
	
	if area is Hitbox and area.target is PlayerController:
		area.target.health -= damage


func update_animation_parms():
	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	if velocity.x != 0 and not audio_walk.playing:
		audio_walk.play()

	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = air_time < 0.5
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
	# anim_tree['parameters/conditions/jump'] = jump_anim_fix > 0
	
	anim_tree['parameters/conditions/attack_forward'] = false
	anim_tree['parameters/conditions/attack_up'] = false
	anim_tree['parameters/conditions/attack_down'] = false


func shoot():
	audio_attack.play()
	_attack_timer = attack_delay
	var arrow = pck_arrow.instantiate() as AttackBasicProjectile

	arrow.collision_mask = 1 | 2

	var dis = global_position.distance_to(Globals.player.global_position)
	var dir = global_position.direction_to(Globals.player.global_position)
	# arrow.position = global_position + dir
	arrow.global_position = global_position
	arrow.initial_velocity = dir * arrow_speed
#	arrow.target = Globals.player

	get_tree().root.add_child(arrow)


func _on_anim_player_animation_finished(anim_name:StringName):
	if anim_name == "bow_bandit_animations/attack_forward":
		anim_tree.active = true
