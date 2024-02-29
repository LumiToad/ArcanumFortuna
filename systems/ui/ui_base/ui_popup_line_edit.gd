class_name UILineEditPopup
extends UIPopup

@onready var line_edit = %LineEdit

func _on_confirm_button_up():
	close_with_result(line_edit.text)


func _on_decline_button_up():
	close_with_result(false)
