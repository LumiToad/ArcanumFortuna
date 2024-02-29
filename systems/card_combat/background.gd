extends TextureRect

var is_hovered = false


func _input(event):
	if is_hovered and event.is_action_pressed("pickUpCard"):
		SfxOther._SFX_Knock()

func _on_mouse_entered():
	is_hovered = true


func _on_mouse_exited():
	is_hovered = false
