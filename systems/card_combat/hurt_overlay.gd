extends TextureRect

@export var max_cooldown = 1.0

var cooldown = 0.0

func _process(delta):
	visible = cooldown > 0.0
	cooldown = min(cooldown, max_cooldown)
	self_modulate.a = min(cooldown / 0.5, 1)
	if cooldown > 0:
		cooldown -= delta


func add_cooldown(addition):
	cooldown += addition
