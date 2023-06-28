@tool
extends Area2D

signal player_entered

@export var enabled: bool = true : set = _set_enabled

## leave this field empty to do nothing
## otherwise saves the game, and changes scene
@export var change_scene_to: String = ""

func _on_body_entered(body: Node2D):
	if Engine.is_editor_hint():
		return

	if Butler.GROUP_PLAYER in body.get_groups():
		player_entered.emit()
		if not change_scene_to.is_empty():
			Butler.save_game()
			var tween = create_tween()
			tween.tween_property($Sprite, "self_modulate", Color.BLACK, .2)
			tween.tween_property($Sprite, "self_modulate", Color.WHITE, .3)
			tween.tween_interval(0.2)
			tween.tween_callback(Butler.change_scene_to_file.bind(change_scene_to))
			tween.play()


func _set_enabled(v: bool):
	enabled = v
	if enabled:
		$Sprite.self_modulate = Color.WHITE
	else:
		$Sprite.self_modulate = Color(0.09411764889956, 0.30196079611778, 0.3137255012989)
