extends Node

@export var player: Player

func _cutscene_intro_start():
	player.in_cutscene = true
	player.velocity.x = 1
	player.velocity.y = 0
	player.update_animation_parms()

func _cutscene_intro_end():
	player.in_cutscene = false
	player.velocity.x = 0
	player.velocity.y = 0
	player.update_animation_parms()
