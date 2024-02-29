class_name TutorialOverlay
extends Control

var tween : Tween
var clickable_rects : Array[Rect2]

@onready var background_dim = %BackgroundDim


func _process(delta):
	var value : bool
	if clickable_rects.size() > 0:
		for rect in clickable_rects:
			value = rect.has_point(get_global_mouse_position())
			if value:
				break
		set_mouse_filter_passthrough(value)


func fade_background(value, duration):
	var color := Color.BLACK
	color.a = value
	tween = self.create_tween()
	tween.tween_property(background_dim, "color", color, duration).from_current()
	tween.finished.emit()


func set_mouse_filter_passthrough(value : bool):
	background_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE if value else Control.MOUSE_FILTER_STOP
