extends State

signal player_entered_vision(data)
signal player_entered_attack_range()

const DEVIATE = 5
@export var anim_sprite: AnimatedSprite2D
@export var vision_area: Area2D
@export var attack_trigger: Area2D
@export var wall_detector: RayCast2D
@export var pivot: Node2D



func enter(_data):
	vision_area.body_entered.connect(_on_body_entered)
	attack_trigger.body_entered.connect(_on_attack_triggered)
	
	
	if wall_detector.is_colliding():
		anim_sprite.play("Idle")
		return
	if vision_area.monitoring == false:
		return
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			emit_signal("player_entered_vision", {"Position": body.position})
			return
	anim_sprite.play("Idle")

func exit():
	vision_area.body_entered.disconnect(_on_body_entered)
	attack_trigger.body_entered.disconnect(_on_attack_triggered)


func _process(delta):
	var player_position = null
	if vision_area.monitoring == false:
		return
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			player_position = body.global_position
	
	if player_position == null:
		return
	var player_x = player_position.x
	
	if player_x > owner.global_position.x + DEVIATE:
		pivot.scale.x = -abs(pivot.scale.x)
	elif player_x < owner.global_position.x - DEVIATE:
		pivot.scale.x = abs(pivot.scale.x)
	
	if wall_detector.is_colliding():
		return
	
	emit_signal("player_entered_vision", {"Position": player_position})
	



func _on_body_entered(body):
	if body is Player:
		emit_signal("player_entered_vision", {"Position": body.position})


func _on_attack_triggered(body):
	if body is Player:
		emit_signal("player_entered_attack_range")
