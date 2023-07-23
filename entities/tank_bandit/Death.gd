extends State

@export var death_time: float = 1
@export var anim_sprite: AnimatedSprite2D
@export var hurt_box: Area2D


func enter(data):
	hurt_box.set_physics_process(false)
	anim_sprite.set_animation("Idle")
	anim_sprite.set_modulate(Color.DARK_RED)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(owner, "rotation_degrees", 90, death_time)
	tween.tween_property(anim_sprite, "modulate", Color(0.545098, 0, 0, 0), death_time)
	tween.finished.connect(_on_finished)

func _on_finished():
	owner.queue_free()

