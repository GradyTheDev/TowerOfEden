extends CharacterBody2D

@export var attack_delay: float = 2
@export var aggro_range: int = 1000
@export var speed: int = 250
@export var gravity: float = 98
@export var far: int = 100
@export var near: int = 80
@export_flags_2d_physics var sight_mask: int

@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var sprite: Sprite2D = get_node("Sprite")

var _sight_delay: float = 0.2  # sec
var _sight_timer: float = 0  # sec

var _can_hit: bool = false
var _attack_timer: float = 0
var air_time: float = 0

var state: states = states.idle

enum states{
	idle,
	hunting
}


func _ready():
	add_to_group(Globals.GROUP_ENEMY)

	anim_tree.active = true

	health.death.connect(_on_death)
	health.health_changed.connect(_on_health_changed)


func _on_death():
	if not is_inside_tree() or not is_node_ready(): return
	anim_tree.active = false
	anim_player.play("player_animations/death")
	var af = func(a): queue_free()
	anim_player.animation_finished.connect(af, CONNECT_ONE_SHOT)


func _on_health_changed(old: int, new: int):
	if new < old:
		var t = sprite.create_tween()
		t.tween_property(sprite, 'modulate', Color.RED, 0.5)
		t.tween_property(sprite, 'modulate', Color.WHITE, 0.5)
		t.play()


func _physics_process(delta):
	if not health.alive: return

	if _sight_timer > 0:
		_sight_timer -= delta
	else:
		refresh_sight()
	
	_attack_timer = move_toward(_attack_timer, 0, delta)
	
	if Globals.player == null or not Globals.player.health.alive and state == states.hunting:
		state = states.idle

	if state == states.idle:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	elif state == states.hunting:
		var dis := global_position.distance_to(Globals.player.global_position)
		var dir := global_position.direction_to(Globals.player.global_position)
		if dis > far:
			velocity = dir * speed
		elif dis < near:
			velocity = dir * -speed
		else:
			velocity = Vector2.ZERO

		Tools.set_node2D_direction(self, Globals.player.global_position.x >= global_position.x)

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
	if Globals.player != null and Globals.player.health.health > 0:
		var player = Globals.player as Player
		var dis := global_position.distance_to(player.global_position)
		
		if dis < aggro_range:
			var space := get_world_2d().direct_space_state
		
			var query := PhysicsRayQueryParameters2D.create(
				global_position,
				player.global_position,
				sight_mask
			)

			var dict := space.intersect_ray(query)
			var collider = dict.get('collider')
			if collider is Player:
				state = states.hunting
				_can_hit = dis < aggro_range
			else:
				state = states.idle
		else:
			state = states.idle


func update_animation_parms():
	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = air_time < 0.5
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']
	# anim_tree['parameters/conditions/jump'] = jump_anim_fix > 0
	
	# anim_tree['parameters/conditions/attack_forward'] = false
	# anim_tree['parameters/conditions/attack_up'] = false
	# anim_tree['parameters/conditions/attack_down'] = false

	if Globals.player == null: 
		anim_tree['parameters/conditions/attack_forward'] = false
		return
	
	var dis = global_position.distance_to(Globals.player.global_position)
	if _can_hit and _attack_timer <= 0 and dis < 200:
		_attack_timer = attack_delay
		anim_tree['parameters/conditions/attack_forward'] = true
	else:
		anim_tree['parameters/conditions/attack_forward'] = false


func _on_anim_tree_animation_finished(anim_name:StringName):
	anim_tree['parameters/conditions/attack_forward'] = false

