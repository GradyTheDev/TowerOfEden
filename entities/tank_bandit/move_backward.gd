extends State

signal player_vanished()
signal attack_reloaded(data)

enum DIR{LEFT = -1, RIGHT = 1}
const DEVIATE = 5
@export var reload_sec: float = 0.6
@export var speed: float = 70.0
@export var anim_sprite: AnimatedSprite2D
@export var vision_area: Area2D
@export var attack_trigger: Area2D
@export var pivot: Node2D
@onready var attack_reload = $AttackReload
var player_last_position = null
var current_dir = DIR.RIGHT


func enter(data):
	anim_sprite.play("Walk", -0.5, true)
	attack_reload.start(reload_sec)

func exit():
	attack_reload.stop()

func _physics_process(delta):
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			player_last_position = body.global_position
	
	if player_last_position == null:
		emit_signal("player_vanished")
		return
	
	var player_x = player_last_position.x
	
	if player_x > owner.global_position.x + DEVIATE:
		pivot.scale.x = -abs(pivot.scale.x)
		current_dir = DIR.RIGHT
	elif player_x < owner.global_position.x - DEVIATE:
		pivot.scale.x = abs(pivot.scale.x)
		current_dir = DIR.LEFT
	
	owner.set_velocity(Vector2(-current_dir * speed, 0))
	
	owner.move_and_slide()




func _on_attack_reload_timeout():
	for body in attack_trigger.get_overlapping_bodies():
		if body is Player:
			emit_signal("attack_reloaded", {"Position": body.global_position})
			return
	emit_signal("attack_reloaded", {})
	
