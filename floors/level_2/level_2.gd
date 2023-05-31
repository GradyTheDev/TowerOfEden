extends Node2D

@onready var snd = $SoundManager

func _ready():
	soundLogic()

func soundLogic():
	snd.playSound(0)
