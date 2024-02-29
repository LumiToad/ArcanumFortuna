class_name OptionsMenu
extends UIBase

var audio_box
var video_box


func setup():
	audio_box = %AudioOptions
	video_box = %VideoOptions
	audio_box.visible = true
	video_box.visible = false


func _input(event):
	super._input(event)
	if event.is_action_released("ui_cancel"):
		if called_by.has_method("close_with_result"):
			close_with_result(true)
		self.close()


func _on_audio_button_button_up():
	audio_box.visible = true
	video_box.visible = false


func _on_video_button_button_up():
	audio_box.visible = false
	video_box.visible = true


func _on_return_button_button_up():
	if called_by.has_method("close_with_result"):
		close_with_result(true)
	else:
		close()

