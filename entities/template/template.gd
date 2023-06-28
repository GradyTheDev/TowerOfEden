extends CharacterBody2D

@onready var anim_tree: AnimationTree = get_node("AnimTree")
@onready var anim_player: AnimationPlayer = get_node("AnimPlayer")
@onready var health: AttributeHealth = get_node("Attributes/AttributeHealth")
@onready var sprite: Sprite2D = get_node("Sprite")


func _ready():
	health.death.connect(_on_death)
	health.health_changed.connect(_on_health_changed)
	# add_to_group(Globals.GROUP_)


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
