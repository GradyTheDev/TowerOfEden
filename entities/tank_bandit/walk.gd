extends FSM_State

signal player_entered_attack_range()
signal walking_target_reached()
signal wall_detected()

enum DIR{LEFT = -1, RIGHT = 1}
const DEVIATE = 5
@export var speed: float = 100.0
@export var vision_area: Area2D
@export var attack_trigger: Area2D
@export var wall_detector: RayCast2D
@export var anim_sprite: AnimatedSprite2D
@export var pivot: Node2D
var player_last_position: Vector2
var current_dir = DIR.LEFT


func enter(data):
	anim_sprite.play("Walk")
	player_last_position = data.Position
	attack_trigger.body_entered.connect(_on_player_in_attack_range)

func exit():
	attack_trigger.body_entered.disconnect(_on_player_in_attack_range)

func _physics_process(delta):
	if wall_detector.is_colliding():
		emit_signal("wall_detected")
		return
	
	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			player_last_position = body.global_position
	
	var player_x = player_last_position.x
	
	if player_x > owner.global_position.x + DEVIATE:
		pivot.scale.x = -abs(pivot.scale.x)
		current_dir = DIR.RIGHT
	elif player_x < owner.global_position.x - DEVIATE:
		pivot.scale.x = abs(pivot.scale.x)
		current_dir = DIR.LEFT

	
	if abs(player_x - owner.global_position.x) < DEVIATE:
		emit_signal("walking_target_reached")
	
	owner.set_velocity(Vector2(current_dir * speed, 0))
	
	owner.move_and_slide()
	
	
	

func _on_player_in_attack_range(body):
	if body is Player:
		emit_signal("player_entered_attack_range")
