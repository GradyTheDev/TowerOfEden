extends OptionButton

@export var entities: Array[PackedScene]

@onready var spawn_pos = $SpawnPos as Node2D
@onready var cage = $Cage as Node

func _ready():
	add_item('None')
	add_item('Clear')
	for pck in entities:
		var e = pck.instantiate()
		add_item(e.name)
	
	if item_count > 2:
		selected = randi_range(1, item_count -1)
		_on_item_selected(selected)


func _on_item_selected(index:int):
	if index == 0:
		return
	elif index == 1:
		for n in cage.get_children():
			n.queue_free()
		return
	
	var pck = entities[index-2]
	var e = pck.instantiate() as Node2D
	e.position = spawn_pos.global_position
	cage.add_child(e)
	self.selected = -1
