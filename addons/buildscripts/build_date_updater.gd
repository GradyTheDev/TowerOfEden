extends EditorExportPlugin

func _get_name() -> String:
	return "build_date_updater"

func _export_begin (
	features: PackedStringArray,
	is_debug: bool,
	path: String,
	flags: int ):
	if ProjectSettings.has_setting("application/config/build_date"):
		var build_date = '{0} UTC'.format([
			Time.get_datetime_string_from_system(true, true)
		])

		ProjectSettings.set_setting("application/config/build_date", build_date)
		# ProjectSettings.save() # Don't save, or you'll have constant Git changes to deal with