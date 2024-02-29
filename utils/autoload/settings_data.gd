class_name SettingsData
extends Node

var settings_dict : Dictionary:
	set(value):
		push_error("ERROR: Tried accessing SettingsData dict, not allowed!")


var fileExtension = ".json"
var savePath = "user://config" + fileExtension


func _ready():
	if load_config() == false:
		save_config()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_DRAG_END:
		await save_config()


func get_settings_dict():
	return settings_dict


func get_current_audio_dict():
	var dict : Dictionary
	var audio_busses = ["Master", "Music", "Ambience", "SFX", "Diagetics", "SFXOther", "Signature", "UI"]
	
	for bus in audio_busses:
		var bus_idx = AudioServer.get_bus_index(bus)
		if bus_idx == -1:
			push_error("BUS %s NOT FOUND!!!" % bus)
			continue
		if not dict.has(bus_idx):
			dict[bus] = AudioServer.get_bus_volume_db(bus_idx)
	return dict


func get_current_video_dict():
	var dict : Dictionary
	
	var resolution = DisplayServer.window_get_size()
	dict["resolution"] = resolution
	dict["window_mode"] = DisplayServer.window_get_mode()
	var pos = DisplayServer.window_get_position_with_decorations()
	dict["window_pos"] = pos
	dict["screen_index"] = DisplayServer.window_get_current_screen()
	
	return dict


func save_config():
	settings_dict["Audio"] = get_current_audio_dict()
	settings_dict["Video"] = get_current_video_dict()
	
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	
	var json = JSON.stringify(settings_dict, "\n", true, false)
	file.store_string(json)
	file.close()


func load_config():
	if not FileAccess.file_exists(savePath):
		print("No config save file found, creating a new one")
		return false
	
	var file = FileAccess.open(savePath, FileAccess.READ)
	
	var json = JSON.new()
	var json_string = file.get_as_text()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	var data = json.get_data()
	settings_dict.merge(data, true)
	file.close()
	return true


func get_loaded_audiosettings():
	return settings_dict["Audio"]


func get_loaded_videosettings():
	return settings_dict["Video"]


func set_video_resolution(resolution):
	if resolution is Vector2i:
		settings_dict["Video"]["resolution"] = resolution
	else:
		push_error("ERROR: resolution not Vector2i")


func get_video_resolution():
	var retVal := Vector2i.ZERO
	var resolution
	if settings_dict["Video"].keys().has("resolution") == false:
		resolution = DisplayServer.window_get_size()
		set_video_resolution(resolution)
	resolution = settings_dict["Video"]["resolution"]
	if resolution is Vector2i:
		retVal = resolution
	elif resolution is String:
		var chars = ["(",")",","]
		for char in chars:
			resolution = resolution.replace(char, "")
		retVal.x = resolution.split(" ")[0] as int
		retVal.y = resolution.split(" ")[1] as int
	return retVal


func set_window_mode(mode):
	if mode is DisplayServer.WindowMode:
		settings_dict["Video"]["window_mode"] = mode
	else:
		push_error("ERROR: mode not DisplayServer.WindowMode")


func get_window_mode():
	var window_mode
	if settings_dict["Video"].keys().has("window_mode") == false:
		set_window_mode(DisplayServer.window_get_mode())
	window_mode = settings_dict["Video"]["window_mode"]
	return window_mode


func set_window_position(position):
	if position is Vector2i:
		settings_dict["Video"]["window_pos"] = position
	else:
		push_error("ERROR: position not Vector2i")


func get_window_position():
	var retVal := Vector2i.ZERO
	var window_pos
	if settings_dict["Video"].keys().has("window_pos") == false:
		window_pos = DisplayServer.window_get_position()
		set_window_position(window_pos)
	window_pos = settings_dict["Video"]["window_pos"]
	if window_pos is Vector2i:
		retVal = window_pos
	elif window_pos is String:
		var chars = ["(",")",","]
		for char in chars:
			window_pos = window_pos.replace(char, "")
		retVal.x = window_pos.split(" ")[0] as int
		retVal.y = window_pos.split(" ")[1] as int
	return retVal


func set_screen_index(index):
	if index is int:
		settings_dict["Video"]["screen_index"] = index
	else:
		push_error("ERROR: screen_index not int")


func get_screen_index():
	if settings_dict["Video"].has("screen_index") == false:
		set_screen_index(DisplayServer.window_get_current_screen())
	return settings_dict["Video"]["screen_index"] as int


func set_audio_slider(bus_name, value):
	settings_dict["Audio"][bus_name] = value
	save_config()


func get_audio_slider(bus_name):
	return settings_dict["Audio"][bus_name] as float
