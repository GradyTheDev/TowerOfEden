class_name Entity
extends CharacterBody2D

@export var health_max: int = 100 : set = _set_health_max
@export var health: int = 100 : set = _set_health
@export var money_for_killing: int = 10
@export var collide_damage: int = 10
@export var invincible: bool = false
@export var activate_anim_tree: bool = true

@export_group('Nodes')
@export var hitbox: Area2D
@export var hurtbox: Area2D
@export var sprite: Sprite2D
@export var anim_tree: AnimationTree
@export var anim_player: AnimationPlayer
@export var debug_line: Line2D


signal took_damage(attacker: Entity, damage: int, health: int)
signal on_death()


func _init():
	add_to_group(Butler.GROUP_ENTITY)


func _ready():
	anim_tree.active = activate_anim_tree


func _set_health(new_health: int):
	new_health = clamp(new_health, 0, health_max)
	if health > 0 and new_health <= 0:
		health = new_health
		on_death.emit()
	else:
		health = new_health


func _set_health_max(v: int):
	if v < health and invincible: return
	health_max = v
	health = health


func hurt(attacker: Entity, amount: int):
	if invincible and amount > 0 or health <= 0: return
	health -= amount
	if health == 0 and attacker.is_in_group(Butler.GROUP_PLAYER):
		attacker.set('money', attacker.get('money') + money_for_killing)
	took_damage.emit(attacker, amount, health)


## [method Tools.set_node2D_direction]
func set_direction(right: bool):
	Tools.set_node2D_direction(self, right)


## [method Tools.get_node2D_direction]
func get_direction() -> int:
	return Tools.get_node2D_direction(self)


## returns direction [br]
## [method Tools.set_node2D_direction] [br]
## [method Tools.get_node2D_direction] [br]
func flip_direction() -> int:
	var dir = get_direction()
	if dir > 0:
		set_direction(false)
	else:
		set_direction(true)
	return get_direction()


func _on_hurtbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if is_ancestor_of(area): return
	if health <= 0: return
	if Butler.paused: return
	
	if hurtbox == null: return # for some reason this is needed

	var my_shape = hurtbox.shape_owner_get_owner(hurtbox.shape_find_owner(local_shape_index))

	if collide_damage != 0 and area is Hitbox and my_shape.name == 'HurtBody' and not (area.collision_layer & 8):
		area.entity.hurt(self, collide_damage)
		return

	hurtbox_entered(
	area,
	area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)),
	my_shape,
	)


## helper function. override this func to use this. [br]
## called after a shape enters the hurtbox 
func hurtbox_entered(their_area: Area2D, their_shape: CollisionShape2D, my_shape: CollisionShape2D):
	pass


func _on_took_damage(attacker: Entity, damage: int, health: int):
	var t = sprite.create_tween()
	t.tween_property(sprite, 'modulate', Color.RED, 0.1)
	t.tween_interval(0.1)
	t.tween_property(sprite, 'modulate', Color.WHITE, 0.1)
	t.play()

func _on_death():
	anim_tree.active = false
	anim_player.play("entity_placeholder_animations/death")
	var af = func(a): queue_free()
	anim_player.animation_finished.connect(af, CONNECT_ONE_SHOT)
