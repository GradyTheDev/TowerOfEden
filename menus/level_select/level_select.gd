extends Control

@onready var btn_template = get_node("btn_template")
@onready var sep_template = get_node("sep_template")

func _ready():
	$Center/Debug.visible = Globals.debug_enabled
	$Center/DebugSep.visible = Globals.debug_enabled

	# Generate buttons for each level
	var last: Control = $Center/DebugSep

	var list = []

	list.append(Globals.SCENE_LEVEL_SELECT)
	
	for key in Globals.LEVELS:
		var b = btn_template.duplicate()
		b.text = key
		b.visible = true
		b.pressed.connect(_generated_button_pressed.bind(Globals.LEVELS[key]))

		var s = sep_template.duplicate()
		s.visible = true

		last.add_sibling(s)
		last.add_sibling(b)
		
		last = s


func _generated_button_pressed(scene: String):
	get_tree().change_scene_to_file(scene)


func _on_exit_pressed():
	SavesManager.save_to_file()
	get_tree().change_scene_to_file(Globals.SCENE_MAIN_MENU)


func _on_debug_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_DEBUG_LEVEL)
