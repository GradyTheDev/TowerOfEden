extends Camera2D


func _process(delta):
	# todo: fix needed when resizing the window, or viewport
	# HUD doesn't scale properly when that happens
	# $UI.size = # actual viewport size

	$UI/PauseMenu.visible = Butler.paused

	# Workaround for bug relating to Camera2D global_postion disconnect from viewport position, and Camera2D's limits
	# the bug causes any normal attempt to get a HUD to follow the viewport to fail, in one way or another
	# canvaslayer follow viewport setting doesn't seem to work at all
	# adding the HUD as a child, makes the children follow the Camera's position, NOT the viewport's position.
	# when the Camera's position limits are hit, the camera's position keeps going, but the viewport stops, messing up the hud placement.
	# So, here im forcefully setting the position of the hud. Makes the hud a bit jittery though
	$UI.global_position = get_screen_center_position() - $UI.size / 2

