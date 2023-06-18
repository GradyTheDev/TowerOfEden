extends Entity

func _ready():
	super()
	health = health_max

func _on_took_damage(attacker: Entity, damage: int, health: int):
	super(attacker, damage, health)
	health = health_max

	var node = $DMGIndicator.duplicate() as Label
	add_child(node)
	node.text = str(damage)
	node.visible = true

	var tween = node.create_tween()

	var speed = randf_range(20, 150) + clamp(damage / 2, 0, 200)
	var displacement = Vector2(speed, speed).rotated(randf_range(-PI, PI))

	tween.tween_property(node, 'position', node.position + displacement, 1)
	tween.tween_callback(node.queue_free)
	tween.play()