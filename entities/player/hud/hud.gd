extends Control

@onready var money = $Money as Label
@onready var health = $Health as Label


func _on_redraw_timeout():
    money.text = "Money: {0}".format([Butler.save.get('money')])
    health.text = "Health: {0}".format([Butler.save.get('health')])
