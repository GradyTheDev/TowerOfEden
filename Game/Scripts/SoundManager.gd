extends Node
class_name SoundManager

# The list of paths to sound files (relative to res://Game/Assets/Audio) managed by this SoundManager instance
@export var soundPaths: Array[String]

# Iterate over all sound paths and add them as an AudioStreamOggVorbis node to this SoundManager
func _ready():
	var cnt: int = 0
	for snd in soundPaths:
		snd = "res://Game/Assets/Audio/" + snd
		var currSoundRes = load(snd) as AudioStreamOggVorbis # Current Sound Resource
		var currSoundNode = AudioStreamPlayer.new() # Current Sound Node
		currSoundNode.set_name("audio_player_%s" % cnt)
		currSoundNode.stream = currSoundRes
		add_child(currSoundNode)
		cnt += 1

# Starts the given sound. When the time argument is given, it will start the sound from that position.
func playSound(key: int, time: float = 0.0):
	get_child(key).play(time)

# Pauses the given sound. Returns the time where the song stopped.
func pauseSound(key: int):
	var elapsed = get_child(key).get_playback_position()
	get_child(key).stop()
	return elapsed

# Switch the audio bus of the given sound.
func switchBus(key: int, bus: String):
	get_child(key).bus = bus as StringName

# Adds a new audio bus to the list of audio buses.
func addBus(bus: String, pos: int):
	AudioServer.add_bus(pos)
	AudioServer.set_bus_name(pos, bus)

# Removes the given bus.
func removeBus(bus: String):
	AudioServer.remove_bus(AudioServer.get_bus_index(bus))

# Adds an audio effect to the given bus.
func addEffectToBus(bus: String, effect: AudioEffect, pos: int):
	AudioServer.add_bus_effect(AudioServer.get_bus_index(bus), effect, pos)

# Removes an audio effect from the given bus.
func removeEffectFromBus(bus: String, pos: int):
	AudioServer.remove_bus_effect(AudioServer.get_bus_index(bus), pos)

# Changes a property of the given effect.
func changeEffectProp(bus: String, pos: int, prop: String, val: Object):
	AudioServer.get_bus_effect_instance(AudioServer.get_bus_index(bus), pos).set(prop, val)

# Alias for timeout function
func wait(time: float):
	await get_tree().create_timer(time).timeout