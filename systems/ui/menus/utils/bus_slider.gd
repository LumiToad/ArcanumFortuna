extends Slider

@export var target_bus := "Master"
var bus_idx = 0
var disabled := false

func _ready():
	bus_idx = AudioServer.get_bus_index(target_bus)
	if bus_idx == -1:
		push_error("BUS %s NOT FOUND!!!" % target_bus)
		return
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	disabled = AudioServer.is_bus_mute(bus_idx)
	set_disabled(disabled)


func set_disabled(is_disabled: bool):
	disabled = is_disabled
	if is_disabled:
		modulate = Color.GRAY
	else:
		modulate = Color.WHITE
	AudioServer.set_bus_mute(bus_idx, disabled)
	get_parent().get_node("CheckBox").button_pressed = not is_disabled

func _on_value_changed(value_changed):
	if not value_changed:
		return
	if bus_idx == -1:
		push_error("BUS %s MISSING!!!" % target_bus)
	
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_idx, db)
	Settings.set_audio_slider(target_bus, db)


func _on_drag_started():
	if disabled:
		set_disabled(false)


func _on_check_box_toggled(toggled_on):
	set_disabled(not toggled_on)
