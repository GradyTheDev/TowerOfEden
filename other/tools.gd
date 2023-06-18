class_name Tools
extends RefCounted

## use this instead of "scale.x = -1"
static func set_node2D_direction(node: Node2D, right: bool):
	if right:
		# right
		node.rotation_degrees = 0
		node.scale.y = 1
	elif not right:
		# left
		node.rotation_degrees = 180
		node.scale.y = -1


## -1 = left  [br]
## 0 = can't tell  [br]
## 1 = right  [br]
static func get_node2D_direction(node: Node2D) -> int:
	if node.scale.y == 1 and node.rotation_degrees == 0:
		return 1 # right
	elif node.scale.y == -1 and abs(node.rotation_degrees) == 180:
		return -1 # left
	else:
		return 0 # unknown


## rotate vector to match the angle and direction of the slope
## used to walk along slopes, instead of bounce off them
static func adjust_vector_to_slope(vector: Vector2, slope_normal: Vector2):
	return vector.rotated(Vector2.UP.angle_to(slope_normal))
