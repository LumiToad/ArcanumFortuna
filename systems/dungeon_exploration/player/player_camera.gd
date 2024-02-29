class_name PlayerCamera extends Camera2D

@export var min_zoom := 0.5
@export var max_zoom := 1.0
@export var zoom_scale := 1.1
@export var lerp_amount := 0.1

@onready var target_zoom = zoom

func _input(event):
	if event.is_action_pressed("zoom_in"):
		target_zoom *= zoom_scale
	elif event.is_action_pressed("zoom_out"):
		target_zoom /= zoom_scale
	else:
		return
	target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)

func _process(delta):
	zoom = zoom.lerp(target_zoom, lerp_amount)
