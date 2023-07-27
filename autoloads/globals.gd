extends Node
## Globals
##
## This class shouldn't reference any custom classes or autoloads

const GROUP_ENEMY := 'enemy'
const GROUP_PLAYER := 'player'
const GROUP_PORTAL := 'portal'

const COLLISION_PLAYER := 2

const SCENE_MAIN_MENU := "res://menus/main_menu/main_menu.tscn"
const SCENE_SETTINGS_MENU := "res://menus/settings/settings.tscn"
const SCENE_CREDITS := "res://menus/credits/credits.tscn"
const SCENE_LEVEL_SELECT := "res://menus/level_select/level_select.tscn"
const SCENE_GAME_OVER := "res://menus/game_over/game_over.tscn"

const SCENE_DEBUG_LEVEL := "res://levels/level_debug/level_debug.tscn"

const ATTRIBUTE_PORTAL_TRANSVERSAL := 'portal_transversal'
const ATTRIBUTE_HEALTH := 'health'
const ATTRIBUTE_MONEY := 'health'
const ATTRIBUTE_SCORE := 'score'

## for runtime operations. Like portal and level select
const LEVELS := {
	"city_floor": "res://levels/city/city_floor.tscn",
	"level_1": "res://levels/level_1/level_1.tscn",
	"bridge_city_to_tower": "res://levels/bridge_city_to_tower/bridge_city_to_tower.tscn"
}

const CUTSCENES := {
	"intro": "res://cutscenes/intro/intro.tscn",
}

## READONLY
## [SettingsManager] is the ONLY thing that is allowed to edit this variable
var debug_enabled: bool = false

var player: Node = null

var is_in_cutscene: bool = false
