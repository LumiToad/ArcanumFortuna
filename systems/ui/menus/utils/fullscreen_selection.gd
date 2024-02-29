extends OptionButton


var options = {
	DisplayServer.WINDOW_MODE_WINDOWED: "Windowed",
	DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: "Fullscreen"
}


func _ready():
	var current_mode = DisplayServer.window_get_mode()
	for i in range(len(options.keys())):
		add_item(options.values()[i], options.keys()[i])
		if current_mode == options.keys()[i]:
			selected = i


func _on_item_selected(index):
	DisplayServer.window_set_mode(options.keys()[index])
	Settings.save_config()
