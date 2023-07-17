extends RichTextLabel

func _process(delta):
	visible = not text.is_empty()
