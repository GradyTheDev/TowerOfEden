extends Control

@onready var resolution: OptionButton = $Center/Resolution
@onready var volume: SpinBox = $Center/Control/Volume

func _ready():
	resolution.set_item_text(0,
	"Default - {0}x{1}".format([Butler.DEFAULT_WINDOW_SIZE.x, Butler.DEFAULT_WINDOW_SIZE.y])
	)
	volume.value = Butler.settings.get(Butler.SETTING_MASTER_VOLUME, 0)

func _on_back_pressed():
	Butler.change_scene_to_file(Butler.SCENE_MAIN_MENU)


func _on_resolution_item_selected(index):	
	match index:
		0:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Butler.DEFAULT_WINDOW_SIZE
			Butler.settings[Butler.SETTING_WINDOW_SIZE] = 'default'
		1:
			get_window().mode = Window.MODE_FULLSCREEN
			Butler.settings[Butler.SETTING_WINDOW_SIZE] = 'fullscreen'
		2:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Vector2(800, 600)
			Butler.settings[Butler.SETTING_WINDOW_SIZE] = '800x600'


func _on_volume_value_changed(value: float):
	Butler.set_setting(Butler.SETTING_MASTER_VOLUME, value)
	print(value, ' ', Butler.settings[Butler.SETTING_MASTER_VOLUME])
