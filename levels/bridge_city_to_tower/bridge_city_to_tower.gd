extends Node2D

# GAME START - EXT. PATH TO EDEN (day)
# FADE IN FROM BLACK
# ...


# TITLE CARD

@onready var bandit_bow = get_node("cutscene/Bandit") as CharacterBody2D
@onready var bandit_sword = get_node("cutscene/CorruptedBandit") as CharacterBody2D
@onready var portal = get_node("portal_end") as Portal
@onready var cutscene = get_node("cutscene/cutscene") as AnimationPlayer

var _cutscene: bool = false
var player: Player

func _ready():
	SoundManager.change_music(SoundManager.MUSIC.main_menu)
	_cutscene = not SavesManager.get_value('progression', 'bridge_city_to_tower', false)
	player = Globals.player as Player
	if _cutscene == true:
		portal.enabled = false
		portal.visible = false

		cutscene.play('intro')
	else:
		get_node("cutscene").queue_free()


func _process(delta):
	if _cutscene:
		if not (is_instance_valid(bandit_bow) or is_instance_valid(bandit_sword)):
			portal.enabled = true
			portal.visible = true
			_cutscene = false
			SavesManager.set_value('progression', 'bridge_city_to_tower', true)


func _cutscene_intro_start():
	player.in_cutscene = true
	player.velocity.x = 1
	player.velocity.y = 0
	Tools.set_node2D_direction(player, true)
	player.update_animation_parms()


func _cutscene_intro_2():
	player.velocity.x = 0
	player.update_animation_parms()


func _cutscene_intro_end():
	player.in_cutscene = false


func _on_talk_to_bandits_trigger_body_entered(body:Node2D):
	if body == player:
		get_node("cutscene/TalkToBanditsTrigger").set_deferred('monitoring', false)

		player.velocity.x = 0
		player.velocity.y = 0
		player.in_cutscene = true
		player.update_animation_parms()

		player.camera_follow_player = false
		cutscene.play('talk_to_bandits', -1, 0.3)


func _cutscene_talk_to_bandits_end():
	player.camera_follow_player = true
	player.in_cutscene = false
	await get_tree().create_timer(0.2)
	bandit_bow.passive = false
	bandit_sword.passive = false