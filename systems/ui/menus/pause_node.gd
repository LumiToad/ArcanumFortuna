class_name PauseNode
extends Node

signal game_paused
signal game_continued

@export_category("Pause Menu")
@export var can_pause = false
@export var pause_scene : PackedScene

func _input(event):
	if not can_pause:
		return
	if event.is_action_released("ui_cancel"):
		await get_tree().process_frame
		if get_tree().paused:
			return
		pause_game()


func continue_game():
	get_tree().paused = false
	game_continued.emit()


func pause_game():
	if not can_pause:
		return
	var pause = SceneHandler.add_ui_element(pause_scene) as PauseMenu
	pause.init(150, self)
	pause.setup()
	get_tree().paused = true
	game_paused.emit()


func is_game_paused():
	return get_tree().paused
