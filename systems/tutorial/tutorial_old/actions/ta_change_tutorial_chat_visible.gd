extends TutorialAction

@export var tutorial_box: TutorialBox

func _execute():
	tutorial_box.visible = false
