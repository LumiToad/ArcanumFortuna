class_name RunEndScreen
extends UIBase

func setup():
	if name == "WinScreen":
		SfxOther._SFX_Win()
	else:
		SfxOther._SFX_Loss()
	Pause.can_pause = false

func _ready():
	SfxOther._SFX_Loss()


func _on_retry_button_button_up():
	for node in SceneHandler.ui_container.get_children():
		if node == self:
			continue
		node.queue_free()
	SceneHandler.change_scene("res://systems/ui/menus/main_menu/main_menu.tscn")
	SceneHandler.current_scene.start_game()
	await get_tree().process_frame
	close()


func _on_main_menu_button_button_up():
	for node in SceneHandler.ui_container.get_children():
		if node == self:
			continue
		node.queue_free()
	SceneHandler.change_scene("res://systems/ui/menus/main_menu/main_menu.tscn")
	close()
