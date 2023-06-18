extends Node2D

func _enter_tree():
	Butler.save['health'] = 100


func _ready():
	Butler.paused = false
	await get_tree().process_frame
	await get_tree().process_frame
	Butler.player.health = 100


func _on_heal_pressed():
	if Butler.player is Player:
		Butler.player.health += 25


func _on_kill_player_pressed():
	if Butler.player is Player:
		Butler.player.health = -10
