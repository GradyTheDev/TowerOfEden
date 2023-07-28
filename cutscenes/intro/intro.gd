extends Control

@onready var lbl = get_node("Developer") as Label

var _exiting: bool = false

var txt = ''

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	SoundManager.change_music(SoundManager.MUSIC.nym_01)

	txt = lbl.text
	lbl.text = ''

var timer = 0
var index = 0
var lines = 0
func _process(delta):
	timer -= delta
	if timer > 0:
		return

	if index >= txt.length():
		timer = 999
		_on_continue_timeout()
		return

	if lines > 3:
		lbl.text = lbl.text.erase(0, lbl.text.find('\n')+1)
		lines -= 1
		timer = 0.5
		return

	lbl.text += txt[index]
	index += 1
	if txt[index-1] == '\n':
		lines += 1
		timer = 0.2
	else:
		timer = 0.03



func _input(event):
	if event.is_action("jump") and Input.is_action_just_pressed("jump"):
		# skip
		_on_continue_timeout()


func _on_continue_timeout():
	if _exiting: return
	_exiting = true

	get_tree().change_scene_to_file(Globals.LEVELS.bridge_city_to_tower)

