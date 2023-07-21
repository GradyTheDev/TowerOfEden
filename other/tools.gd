class_name Tools
extends RefCounted

## use this instead of "scale.x = -1"
static func set_node2D_direction(node: Node2D, right: bool):
	if right:
		# right
		node.rotation_degrees = 0
		node.scale.y = abs(node.scale.y)
	elif not right:
		# left
		node.rotation_degrees = 180
		node.scale.y = -abs(node.scale.y)


## -1 = left  [br]
## 0 = can't tell  [br]
## 1 = right  [br]
static func get_node2D_direction(node: Node2D) -> int:
	var scale_y = round(node.scale.y)
	var rotation = round(abs(node.rotation_degrees))

	if scale_y > 0 and rotation == 0:
		return 1 # right
	elif scale_y < 0 and rotation == 180:
		return -1 # left
	else:
		return 0 # unknown


## returns new direction
static func flip_node2D_direction(node: Node2D) -> int:
	var direction = get_node2D_direction(node)
	set_node2D_direction(node, direction < 1)
	return get_node2D_direction(node)


## rotate vector to match the angle and direction of the slope
## used to walk along slopes, instead of bounce off them
static func adjust_vector_to_slope(vector: Vector2, slope_normal: Vector2):
	return vector.rotated(Vector2.UP.angle_to(slope_normal))


static func duplicate_config(conf: ConfigFile) -> ConfigFile:
	if conf == null: return null
	var o = ConfigFile.new()

	for section in conf.get_sections():
		for key in conf.get_section_keys(section):
			o.set_value(section, key, conf.get_value(section, key))
	
	return o


static func modulate_node(node: Node2D, time: float, a: Color, b: Color):
	var t = node.create_tween()
	t.tween_property(node, 'modulate', a, time/2)
	t.tween_property(node, 'modulate', b, time/2)
	t.play()
