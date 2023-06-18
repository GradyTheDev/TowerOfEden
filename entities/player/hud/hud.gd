extends Control

@export var player: Player

@onready var money = $Money as Label
@onready var health = $Health as Label


func _on_redraw_timeout():
	money.text = "Money: {0}".format([player.money])
	health.text = "Health: {0} / {1}".format([player.health, player.health_max])
