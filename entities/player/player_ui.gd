extends Control

@export var atr_health: AttributeHealth
@export var atr_money: AttributeMoney

@onready var ui_health = get_node("HUD/Health")
@onready var ui_money = get_node("HUD/Money")

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready():
	_on_redraw_timeout()


func _process(delta):
	$PauseMenu.visible = get_tree().paused


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
	
