class_name ScreenshakeCamera2D
extends Camera2D

@export var noise := FastNoiseLite.new()
@export var intensity := 1.0
@export var speed := 1.0

var trauma := 0.0
var prev_camera: Camera2D

func _ready():
	prev_camera = get_viewport().get_camera_2d()
	make_current()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(prev_camera):
			prev_camera.make_current()


func _process(delta):
	var impact = trauma * trauma
	global_position = get_viewport_rect().get_center()
	var move_x = noise.get_noise_2d(Time.get_ticks_msec() * speed, 0) * intensity
	var move_y = noise.get_noise_2d(0, Time.get_ticks_msec() * speed) * intensity
	rotation_degrees = lerpf(0, noise.get_noise_2d(Time.get_ticks_msec() * speed, Time.get_unix_time_from_system() * speed) * intensity, impact)
	offset = lerp(Vector2.ZERO, Vector2(move_x, move_y), impact)

	if trauma > 0:
		trauma -= 0.01
	zoom = lerp(Vector2.ONE, Vector2.ONE * 1.1, impact)
	trauma = clampf(trauma, 0, 1)


func add_trauma(amount):
	trauma += amount
