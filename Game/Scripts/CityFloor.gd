extends Node2D
class_name CityFloor

@onready var snd = $SoundManager

func _ready():
	soundLogic()

func soundLogic():
	snd.playSound(0)
