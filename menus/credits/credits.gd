extends Control

@onready var score = get_node("score") as Label

func _ready():
	if Globals.score == -1.123456789:
		score.visible = false
	
	score.text = 'Score: %0.2f' % Globals.score

func _on_exit_pressed():
	get_tree().change_scene_to_file(Globals.SCENE_MAIN_MENU)
