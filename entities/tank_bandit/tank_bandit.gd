extends CharacterBody2D

const GRAVITY = 100
@export var dialog_text: String:
	set(new_text):
		dialog_text = new_text
		dialog.set_text(new_text)
@export var is_passive: bool = false:
	set(val):
		is_passive = val
		if is_passive == false:
			for detector in detectors:
				detector.monitoring = true
		if is_passive == true:
			for detector in detectors:
				detector.monitoring = false
			anim_sprite.set_animation("Idle")
			fsm.change_state_to(StateMachine.STATE.IDLE, {})
@export var hurt_color: Color
@export var heal_color: Color
@export var no_dmg_color: Color
@onready var detectors = [$Pivot/VisionBox, $Pivot/AttackTrigger]
@onready var dialog = $Dialog
@onready var fsm: StateMachine = $FSM
@onready var anim_sprite = $Pivot/AnimatedSprite2D



func _process(delta):
	if not self.is_on_floor():
		velocity.y = GRAVITY
		move_and_slide()

func show_health_change(difference):
	if difference < 0:
		self.set_modulate(hurt_color)
	elif difference > 0:
		self.set_modulate(heal_color)
	else:
		self.set_modulate(no_dmg_color)
	await get_tree().create_timer(0.1).timeout
	self.set_modulate(Color.WHITE)



func _on_idle_player_entered_vision(data):
	fsm.change_state_to(StateMachine.STATE.WALK, data)


func _on_walk_player_entered_attack_range():
	fsm.change_state_to(StateMachine.STATE.ATTACK, {})

func _on_idle_player_entered_attack_range():
	fsm.change_state_to(StateMachine.STATE.ATTACK, {})


func _on_walk_walking_target_reached():
	fsm.change_state_to(StateMachine.STATE.IDLE, {})

func _on_attack_attack_ended():
	fsm.change_state_to(StateMachine.STATE.MOVEBACKWARD, {})

func _on_move_backward_attack_reloaded(data):
	if data == {}:
		fsm.change_state_to(StateMachine.STATE.IDLE, data)
	else:
		fsm.change_state_to(StateMachine.STATE.ATTACK, data)

func _on_move_backward_player_vanished():
	fsm.change_state_to(StateMachine.STATE.IDLE, {})

func _on_walk_wall_detected():
	fsm.change_state_to(StateMachine.STATE.IDLE, {})

func _on_health_death():
	fsm.change_state_to(StateMachine.STATE.DEATH, {})


func _on_health_health_changed(old, new):
	show_health_change(new - old)




