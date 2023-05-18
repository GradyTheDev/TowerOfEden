extends Node2D
class_name CityFloor

@onready var snd = $SoundManager

func _ready():
	pass
	# soundLogic()

func soundLogic():
	snd.playSound(0)
	await snd.wait(5)
	snd.addBus("Effects", 1)
	snd.addEffectToBus("Effects", AudioEffectPhaser.new(), 1)
	snd.switchBus(0, "Effects")
	await snd.wait(5)
	snd.switchBus(0, "Master")
	snd.removeBus("Effects")
	await snd.wait(5)
	snd.pauseSound(0)
	await snd.wait(1)
	snd.playSound(0, 30)
