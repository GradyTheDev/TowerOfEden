extends Node2D

signal act_ended()

@onready var bandit_bow = $BanditBow
@onready var bandit_sword = $BanditSword
var bandits = 2

func _ready():
	bandit_bow.get_node("Attributes/Health").death.connect(_on_bandit_dead)
	bandit_sword.get_node("Attributes/Health").death.connect(_on_bandit_dead)
	

func _on_bandit_dead():
	bandits -= 1
	if bandits <= 0:
		emit_signal("act_ended")
