extends EditorInspectorPlugin

var LayerEditor = preload("res://addons/dynasic/editor/properties/layer_property.gd")

func _can_handle(object):
	if object is Track:
		return true
	
	return false


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	# if type == TYPE_OBJECT and name == "layers":
		# add_property_editor(name, LayerEditor.new())
		# return true
	return false
