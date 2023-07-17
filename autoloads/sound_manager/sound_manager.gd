extends Node

@onready var _music: AudioStreamPlayer = get_node("Music")

const MUSIC := {
	'main_menu': preload('res://assets/music/main-menu.ogg'),
	'nym_01': preload('res://assets/music/nym-01.ogg')
}


func change_music(stream: AudioStream):
	_music.stream = stream
	_music.play()


func _on_music_finished():
	_music.play()

