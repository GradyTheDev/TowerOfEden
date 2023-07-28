extends CharacterBody2D

@export var enable_collision: bool

@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
@onready var health: AttributeHealth = get_node("Attributes/Health")
@onready var sprite: Sprite2D = get_node("Sprite")
@onready var dmg_indicator: Label = get_node("DMGIndicator")
@onready var heal_indicator: Label = get_node("HealIndicator")

# internal. avoid infinite recursion. see [method _on_health_changed]
var _setting_health: bool

func _ready():
	health.health = health.health_max/2
	health.health_changed.connect(_on_health_changed)
	add_to_group(Globals.GROUP_ENEMY)

	$ColBody.disabled = not enable_collision



func _on_health_changed(old: int, new: int):
	if _setting_health: return
	
	if new < old:
		_setting_health = true
		health.health = health.health_max/2

		Tools.modulate_node(sprite, 0.5, Color.RED, Color.WHITE)

		var node = dmg_indicator.duplicate() as Label
		add_child(node)
		node.global_position = global_position
		var damage = old - new
		node.text = str(damage)
		node.visible = true

		send_flying(node, damage)
		_setting_health = false

	elif new > old:
		_setting_health = true
		health.health = health.health_max/2

		Tools.modulate_node(sprite, 0.5, Color.GREEN, Color.WHITE)

		var node = heal_indicator.duplicate() as Label
		add_child(node)
		node.global_position = global_position
		var damage = new - old
		node.text = str(damage)
		node.visible = true

		send_flying(node, damage)
		_setting_health = false


## add node to scene_tree before calling this
func send_flying(node: Node, damage: float):
	assert(node.is_inside_tree(), "add node to scene_tree before calling this")

	var tween = node.create_tween()

	var speed = randf_range(20, 150) + clamp(damage / 2, 0, 200)
	var displacement = Vector2(speed, speed).rotated(randf_range(-PI, PI))

	tween.tween_property(node, 'position', node.position + displacement, 1)
	tween.tween_callback(node.queue_free)
	tween.play()
