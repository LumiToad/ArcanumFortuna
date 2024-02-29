extends TutorialCondition

@export var button : Button

var executed := false

func _setup():
	button.show()
	button.pressed.connect(_on_button_pressed)


func _completed() -> bool:
	return executed


func _on_button_pressed():
	executed = true
	button.hide()
