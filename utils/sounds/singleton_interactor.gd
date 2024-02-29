extends Node

@export_enum("BG:0", "OTHER:1") var singleton = 0
@export var method_to_call := ""
@export var on_ready := false
@export var connect_signal := ""


func _ready():
	if on_ready:
		execute()
	
	if not connect_signal.is_empty():
		get_parent().connect(connect_signal, execute)


func execute():
	if singleton == 0:
		if SfxBg.has_method(method_to_call):
			SfxBg[method_to_call].call()
			return
	elif singleton == 1:
		if SfxOther.has_method(method_to_call):
			SfxOther[method_to_call].call()
			return
	push_error("Couldn't find method %s" % method_to_call)
