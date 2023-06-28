class_name AttributePortalTransversal
extends Attribute

## AttributePortalTransversal
##
## see [Portal]

## portal name without the prefix "portal_"
## [br]any [Portal] must have the prefix "portal_"
## [br]also is the last portal to be used
var last_portal: String

## portal name without "portal_"
## [br]any [Portal] should be named "portal_"+unique name
## [br]Cleared after teleporting through a portal
var to_portal: String

func _init():
	super(Globals.ATTRIBUTE_PORTAL_TRANSVERSAL)


func _ready():
	if to_portal.is_empty() and not last_portal.is_empty():
		to_portal = last_portal
	
	if body.is_node_ready():
		teleport()
	else:
		body.ready.connect(teleport, CONNECT_ONE_SHOT)


func _save_start():
	if not save: return
	_save_sub_attribute('last_portal')
	_save_sub_attribute('to_portal')


func _load_start():
	if not save: return
	_smart_load_sub_attribute('last_portal', '')
	_smart_load_sub_attribute('to_portal', '')


## teleports [member Attribute.body] to [member to_portal] if it exists 
func teleport():
	if body is Node2D:
		var local_portal = null
		var fportal = null

		var pname = "portal_" + to_portal.trim_prefix('portal_')
		var from = "portal_" + last_portal.trim_prefix('portal_')
		for portal in get_tree().get_nodes_in_group(Globals.GROUP_PORTAL):
			if pname == portal.name and portal.exit_pos != null:
				local_portal = portal
			if from == portal.name and portal.exit_pos != null:
				fportal = portal
			if local_portal != null and fportal != null: break
		
		if local_portal == null:
			if body.is_in_group(Globals.GROUP_PLAYER):
				if fportal != null:

					if not to_portal.is_empty():
						last_portal = to_portal
					
					to_portal = ''
					SavesManager.save_to_file()
					get_tree().change_scene_to_file(fportal.get_scene_path())
			else:
				body.queue_free()
		else:
			body.global_position = local_portal.exit_pos.global_position
			
			if to_portal.is_empty():
				last_portal = local_portal.name
			else:
				last_portal = to_portal
			
			to_portal = ''



	
	
