extends Node2D

var health: int = 9999 : set = _set_health


func _set_health(v: int):
	print("Took DMG: ", health - v)

	var node = $DMGIndicator.duplicate() as Label
	add_child(node)
	node.text = str(health - v)
	node.visible = true

	var tween = node.create_tween()
	var displacement = Vector2(
		randi_range(-100, 100),
		randi_range(-100, 100)
	)
	tween.tween_property(node, 'position', node.position + displacement, 1)
	tween.tween_callback(node.queue_free)
	tween.play()