extends CharacterBody2D

@export var health: int = 100 : set = _set_health
@export var damage: int = 10
@export var speed: int = 100

var moving_right: bool = false

func _process(delta):
	if Butler.paused:
		return

	if moving_right:
		$Sprite.flip_h = false
		velocity = Vector2.RIGHT * speed
		velocity.y += 35
		var gpos = global_position
		move_and_slide()
		if gpos.is_equal_approx(global_position):
			moving_right = false
	else:
		$Sprite.flip_h = true
		velocity = Vector2.LEFT * speed
		velocity.y += 35
		var gpos = global_position
		move_and_slide()
		if gpos.is_equal_approx(global_position):
			moving_right = true


func _set_health(v: int):
	if v < health:
		var tween = create_tween()
		tween.tween_property($Sprite, 'self_modulate', Color.RED, .05)
		tween.tween_property($Sprite, 'self_modulate', Color.WHITE, .05)
		tween.play()
	
	health = v
	if health <= 0:
		Butler.save.money += 10
		queue_free()


func _on_hurtbox_area_entered(area:Area2D):
	var target = area.get_parent()
	if Butler.GROUP_PLAYER in target.get_groups():
		assert(target.get('health') is int, 'Missing "health" variable in this node -> ' + target.name + ":" + target.get_class())
		if target.health > 0:
			target.health -= damage
			if OS.is_debug_build():
				print(name, ' hit ', target.name, ' hp: ', target.health)
