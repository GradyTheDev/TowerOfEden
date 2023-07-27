extends Node

signal scene_entered
signal scene_ready
signal scene_exiting
signal scene_exited


func _enter_tree():
	get_tree().root.child_entered_tree.connect(_child_entered_tree)


func _child_entered_tree(n: Node):
	if get_tree().current_scene == n:
		n.tree_entered.connect(_tree_entered, CONNECT_ONE_SHOT)
		n.ready.connect(_scene_ready, CONNECT_ONE_SHOT)
		n.tree_exiting.connect(_scene_exiting, CONNECT_ONE_SHOT)
		n.tree_exited.connect(_scene_exited, CONNECT_ONE_SHOT)


func _scene_ready():
	if not is_inside_tree(): return
	scene_ready.emit()
	get_tree().paused = false


func _scene_exiting():
	if not is_inside_tree(): return
	scene_exiting.emit()
	get_tree().paused = true


func _scene_exited():
	if not is_inside_tree(): return
	scene_exited.emit()


func _tree_entered():
	if not is_inside_tree(): return
	scene_entered.emit()
