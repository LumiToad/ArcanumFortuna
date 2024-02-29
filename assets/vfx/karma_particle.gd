extends GPUParticles2D


func set_text(new_text):
	$text.text = new_text
	$text.visible = true


func set_color(new_color: Color):
	modulate = new_color
