extends Control

@export var lifetime = 2.0
@export var speed = 50

func setup(damage):
	%Amount.text = str(damage)


func _process(delta):
	lifetime -= delta
	global_position += Vector2.UP * (2 - lifetime) * speed * delta
	modulate.a = pow(clamp(lifetime, 0, 0.5) * 2, 2)
	if lifetime < 0:
		queue_free()
