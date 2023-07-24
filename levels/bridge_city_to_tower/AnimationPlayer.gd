extends AnimationPlayer

var current_speed_scale = self.get_speed_scale()

func _unhandled_input(event):
	if event.is_action_pressed("jump")\
			and self.is_playing():
		self.set_speed_scale(10)


func _on_animation_finished(anim_name):
	self.set_speed_scale(current_speed_scale)
