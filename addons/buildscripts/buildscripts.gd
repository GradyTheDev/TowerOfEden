@tool
extends EditorPlugin

const script_build_date_updater = preload("res://addons/buildscripts/build_date_updater.gd")
var build_date_updater = script_build_date_updater.new()

func _enter_tree():
	# Initialization of the plugin goes here.
	add_export_plugin(build_date_updater)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(build_date_updater)
