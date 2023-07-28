extends Node2D

signal act_ended()

@onready var tank_bandit = $TankBandit



func _ready():
	tank_bandit.get_node("Attributes/Health").death.connect(_on_tank_bandit_death)



func _on_tank_bandit_death():
	get_parent().get_node("Act3/Separator/BanditKneeling").global_position = tank_bandit.global_position
	tank_bandit.visible = false
	emit_signal("act_ended")
