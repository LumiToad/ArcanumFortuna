extends EditorProperty

var property_control = VBoxContainer.new()
var stream: AudioStream
var loudness: float
var updating := false

func _init():
	var label = Label.new()
	label.text = "TEST"
	property_control.add_child(label)
	
	refresh_control()


func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	for value in new_value:
		pass
	updating = false


func refresh_control():
	pass
