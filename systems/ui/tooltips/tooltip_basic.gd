class_name TooltipBasic
extends TooltipBase

func _process(delta):
	%Background.global_position = Vector2.ZERO
	move_to_mouse_pos(get_child(0).get_global_rect())


func setup(title: String, texture: Texture2D, text: String):
	visible = false
	%Name.text = title
	%Text.text = text
	await SceneHandler.shelf.get_tree().create_timer(0.1).timeout
	visible = true
