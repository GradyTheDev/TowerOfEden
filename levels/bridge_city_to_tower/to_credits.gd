extends Node

@export var last_cutscene: String

func _on_animation_player_animation_finished(anim_name:StringName):
	if anim_name == last_cutscene:
		get_tree().change_scene_to_file(Globals.SCENE_CREDITS)
