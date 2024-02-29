extends GPUParticles2D

@export var worse_digit = -10
@export var best_digit = 10
@export_color_no_alpha var good_modulate: Color
@export_color_no_alpha var bad_modulate: Color


var count = 0
var target
var original_position = Vector2(1920 / 2, 1080 / 2)

func _ready():
	target = bad_modulate.lerp(good_modulate, float(clamp(count, worse_digit, best_digit) + 10) / 20)


func _process(delta):
	self_modulate = self_modulate.lerp(target, 0.1)
	$trail.self_modulate = self_modulate
	
	global_position = global_position.lerp(original_position, 0.1)


func update_number(mod_number: int):
	count += mod_number
	%Count.text = str(count)
	
	SfxOther._SFX_Blip(count)
	target = bad_modulate.lerp(
		good_modulate,
		float(clamp(count, worse_digit, best_digit) + abs(worse_digit))
		/ (abs(worse_digit) + best_digit))


func delete():
	emitting = false
	$trail.emitting = false
	$Count.visible = false
	await get_tree().create_timer(2).timeout
	queue_free()
