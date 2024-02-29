extends Label

var is_hovered = false
var seed := ""

func set_seed(seed_txt : String):
	seed = seed_txt
	text = "Seed: " + seed

func _input(event):
	if not is_hovered:
		return
	if event is InputEventMouseButton && event.is_double_click():
		self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		var current_clipboard = DisplayServer.clipboard_get()
		if current_clipboard == seed:
			return
		DisplayServer.clipboard_set(seed)


func _on_mouse_entered():
	is_hovered = true
	scale = Vector2(1, 1.1)


func _on_mouse_exited():
	is_hovered = false
	scale = Vector2.ONE
