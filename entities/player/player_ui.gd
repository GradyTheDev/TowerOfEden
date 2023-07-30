extends Control

@export var atr_health: AttributeHealth
@export var atr_money: AttributeMoney
@export var atr_score: AttributeScore

@onready var ui_health = get_node("HUD/Health") as Label
@onready var ui_money = get_node("HUD/Money") as Label
@onready var ui_score = get_node("HUD/Score") as Label

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready():
	_on_redraw_timeout()


func _process(delta):
	$PauseMenu.visible = get_tree().paused
	visible = not Globals.is_in_cutscene


func _on_level_select_pressed():
	SavesManager.save_to_file()
	get_tree().change_scene_to_file(Globals.SCENE_LEVEL_SELECT)


func _on_exit_pressed():
	SavesManager.save_to_file()
	get_tree().change_scene_to_file(Globals.SCENE_MAIN_MENU)


func _on_redraw_timeout():
	if atr_money != null:
		ui_money.text = "Money: {0}".format([atr_money.money])
	
	if atr_health != null:
		ui_health.text = "Health: {0} / {1}".format([atr_health.health, atr_health.health_max])
	
	if atr_score != null:
		ui_score.text = "Score: {0}".format([atr_score.score])
