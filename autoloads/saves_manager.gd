extends Node

signal save_start
signal save_finished

## after config file is loaded, but before all nodes have updated
signal load_start

## after all nodes have finished updating
signal load_finished

const SAVE_DIRECTORY := 'user://saves/'

## this is the current COPY of the game state
## [br] use [method set_value] and [method get_value] instead of interacting directly
## [br]when an object gets deleted, copy it's values to this
## [br]when that object is spawned again, load the values from here
var current: ConfigFile = null

var saves: Array[ConfigFile]

func _ready():
	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		DirAccess.make_dir_absolute(SAVE_DIRECTORY)
	scan_for_saves()

	if FileAccess.file_exists(SAVE_DIRECTORY + 'current_game.txt'):
		var s = FileAccess.get_file_as_string(SAVE_DIRECTORY + 'current_game.txt').strip_escapes()
	
		if s is String:
			load_save(s)


func scan_for_saves():
	saves.clear()

	for file_name in DirAccess.get_files_at(SAVE_DIRECTORY):
		if '.ini' in file_name:
			var conf = ConfigFile.new()
			var err = conf.load(SAVE_DIRECTORY + file_name)
			if err != OK: continue
			conf.set_value('save', 'name', file_name.trim_suffix('.ini'))
			saves.append(conf)


func load_save(save_name: String):
	for s in saves:
		if s.get_value('save', 'name', null) == save_name:
			current = Tools.duplicate_config(s)

			var f = FileAccess.open(SAVE_DIRECTORY + 'current_game.txt', FileAccess.WRITE)
			f.store_string(save_name)

			# tell nodes to update
			load_start.emit()

			# tell nodes loading is finished
			load_finished.emit()
			break


## resets current save
func reload_save():
	if current == null: return
	var n = current.get_value('save', 'name')
	load_save(n)


func save_to_file():
	if current == null: return
	
	current.set_value('save', 'datetime', Time.get_datetime_string_from_system(true))

	# tell nodes to copy persistant data
	save_start.emit()

	var fname = current.get_value('save', 'name', null)
	if fname == null: 
		fname = current.get_value('save', 'datetime')
		current.set_value('save', 'name', fname)
	
	current.set_value('save', 'name', null)
	current.save(SAVE_DIRECTORY + fname + '.ini')
	current.set_value('save', 'name', fname)

	var f = FileAccess.open(SAVE_DIRECTORY + 'current_game.txt', FileAccess.WRITE)
	f.store_string(fname)

	var add = true
	for i in len(saves):
		if saves[i].get_value('save', 'name') == current.get_value('save', 'name'):
			saves[i] = Tools.duplicate_config(current)
			add = false
			break
	
	if add:
		saves.append(Tools.duplicate_config(current))


	# tell nodes saving is finished
	save_finished.emit()


## also loads the new save
func new_save(save_name: String = ''):
	if save_name.is_empty():
		save_name = Time.get_datetime_string_from_system(true)
	
	save_name = save_name.validate_filename()

	var conf = ConfigFile.new()
	var err = conf.save(SAVE_DIRECTORY + save_name + '.ini')
	if err != OK:
		print_debug("failed to create new game save: ", error_string(err))
		return
	
	conf.set_value('save', 'name', save_name)
	saves.append(conf)

	load_save(save_name)


func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if current == null or not current.has_section_key(section, key):
		return default
	else:
		return current.get_value(section, key)


func set_value(section: String, key: String, value: Variant):
	if current != null:
		current.set_value(section, key, value)


func has_key(section: String, key: String) -> bool:
	if current == null: return false
	return current.has_section_key(section, key)
