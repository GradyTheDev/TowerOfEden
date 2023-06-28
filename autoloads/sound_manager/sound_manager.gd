extends Node

@onready var music: AudioStreamPlayer = get_node("Music")


func _on_music_finished():
	music.play()
