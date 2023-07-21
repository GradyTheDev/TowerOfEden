extends RichTextLabel

var is_reversed = false

func _process(delta):
	visible = not text.is_empty()
