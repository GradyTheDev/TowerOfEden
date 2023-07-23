extends State

signal attack_ended()

@export var damage = 24
@export var attack_range: Area2D
@export var anim_sprite: AnimatedSprite2D


func enter(data):
	anim_sprite.play("Attack")
	anim_sprite.animation_finished.connect(_on_animation_finished)
	anim_sprite.frame_changed.connect(_on_frame_changed)

func exit():
	anim_sprite.animation_finished.disconnect(_on_animation_finished)
	anim_sprite.frame_changed.disconnect(_on_frame_changed)
	


func _on_frame_changed():
	var frame = anim_sprite.get_frame()
	if frame == 4:
		make_damage()

func make_damage():
	var areas := attack_range.get_overlapping_areas()
	for area in areas:
		if not area is Hitbox or area.health == null: continue
		var id := area.get_instance_id()
		area.health.health -= damage

func _on_animation_finished():
	emit_signal("attack_ended")
