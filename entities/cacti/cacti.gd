extends CharacterBody2D

@export var speed: float = 90

@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
@onready var health: AttributeHealth = get_node("Attributes/AttributeHealth")
@onready var sprite: Sprite2D = get_node("Sprite")

var direction_swith_delay: float = 1
var direction_switch_timer: float = 0

var air_time: float = 0

func _init():
	super()
	add_to_group(Globals.GROUP_ENEMY)


func _ready():
	anim_tree.active = true


func _physics_process(delta: float):
	if not health.alive: return
	
	direction_switch_timer -= delta

	velocity.x = speed * Tools.get_node2D_direction(self)
	if not is_on_floor():
		velocity.y = 98

	move_and_slide()
	var rv = get_real_velocity().abs()

	if rv.x < 0.01:
		if direction_switch_timer <= 0:
			direction_switch_timer = direction_swith_delay
			Tools.flip_node2D_direction(self)
	
	if is_on_floor():
		air_time = 0
	else:
		air_time += delta

	anim_tree['parameters/conditions/walk'] = velocity.x != 0
	anim_tree['parameters/conditions/idle'] = not anim_tree['parameters/conditions/walk']
	anim_tree['parameters/conditions/on_ground'] = air_time < 0.5
	anim_tree['parameters/conditions/in_air'] = not anim_tree['parameters/conditions/on_ground']


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
