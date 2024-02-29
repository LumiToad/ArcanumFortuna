extends Node

@export_enum("Show: 1", "Hide: 0") var show_or_hide = 1
@export var feature := "web"
@export var delete := false

func _ready():
	if OS.has_feature(feature):
		get_parent().visible = show_or_hide
		if delete:
			get_parent().queue_free()
