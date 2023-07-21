extends Node2D

enum {INTRO, ACT1, ACT2, ACT3}

@export var animation_speed = {
	INTRO: 1.0,
	ACT1: 1.0,
	ACT2: 1.0,
	ACT3: 1.0,
}

var starting_act = ACT1

@onready var acts =  {
	ACT1: %Act1,
	ACT2: %Act2,
	ACT3: %Act3,
}
@onready var portal = $portal_end
@onready var player = $Player



func _ready():
	SoundManager.change_music(SoundManager.MUSIC.main_menu)
	portal.enabled = false
	portal.visible = false
	
	var progress = SavesManager.get_value('progression', 'bridge_city_to_tower')
	match progress:
		null:
			start_act(INTRO)
		INTRO:
			starting_act = ACT1
		ACT1:
			starting_act = ACT2
		ACT2:
			printerr("Shouldn't be saved on act 2")
		ACT3:
			$CutsceneTrigger.monitoring = false
			open_portal()


func start_act(act: int):
	await act_setup(act)
	$AnimationPlayer.play("Act" + str(act), -1, animation_speed[act])

func act_setup(act):
	await prepare_player_to_cutscene()
	
	match act:
		INTRO:
			pass
		ACT1:
			player.camera.enabled = false
			acts[ACT1].position = player.global_position
			Tools.set_node2D_direction(player, true)
		ACT2:
			player.camera.enabled = false
			acts[ACT2].position = player.global_position
			Tools.set_node2D_direction(player, true)
		ACT3:
			player.camera.enabled = false
			acts[ACT3].position = player.global_position
			Tools.set_node2D_direction(player, true)

func prepare_player_to_cutscene():
	player.in_cutscene = true
	player.velocity.x = 0
	player.velocity.y = 0
	while not player.is_on_floor():
		await get_tree().physics_frame
	player.update_animation_parms()


func open_portal():
	portal.enabled = true
	portal.visible = true


func _on_cutscene_triggered(body):
	start_act(starting_act)

func _on_act_1_act_ended():
	start_act(ACT2)

func _on_act_2_act_ended():
	start_act(ACT3)


func _on_animation_player_animation_finished(anim_name):
	player.camera.enabled = true
	player.in_cutscene = false
	var progress_name = null
	match anim_name:
		"Intro":
			progress_name = INTRO
		"Act1":
			progress_name = ACT1
		"Act3":
			progress_name = ACT3
			open_portal()
	SavesManager.set_value('progression', 'bridge_city_to_tower', progress_name)



