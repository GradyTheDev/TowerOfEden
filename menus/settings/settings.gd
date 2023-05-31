extends Control

@onready var resolution: OptionButton = $Center/Resolution

func _ready():
	resolution.set_item_text(0,
	"Default - {0}x{1}".format([Butler.DEFAULT_WINDOW_SIZE.x, Butler.DEFAULT_WINDOW_SIZE.y])
	)


func _on_back_pressed():
	Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)


func _on_resolution_item_selected(index):	
	match index:
		0:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Butler.DEFAULT_WINDOW_SIZE
			Butler.settings.window_size = 'default'
		1:
			get_window().mode = Window.MODE_FULLSCREEN
			Butler.settings.window_size = 'fullscreen'
		2:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Vector2(800, 600)
			Butler.settings.window_size = '800x600'
