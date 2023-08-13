extends Node

@onready var _music: AudioStreamPlayer = get_node("Music")
@onready var button_click: AudioStreamPlayer = get_node("Button_Click")
@onready var button_hover: AudioStreamPlayer = get_node("Button_Hover")

const MUSIC := {
	'main_menu': preload('res://assets/music/main-menu.ogg'),
	'nym_01': preload('res://assets/music/nym-01.ogg')
}

func _ready():
	get_tree().node_added.connect(_node_added)


func change_music(stream: AudioStream):
	_music.stream = stream
	_music.play()


func _on_music_finished():
	_music.play()


func _btn_pressed():
	button_click.play()

func _btn_hover():
	button_hover.play()


func _node_added(n: Node):
	n = n as Button
	if n != null:
		n.pressed.connect(_btn_pressed)
		n.mouse_entered.connect(_btn_hover)
	