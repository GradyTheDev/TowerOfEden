extends Node2D


func _on_heal_pressed():
	if Globals.player != null:
		Globals.player.health.health += 25


func _on_hurt_pressed():
	if Globals.player != null:
		Globals.player.health.health -= 25
