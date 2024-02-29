extends TutorialAction

@export var actor_name: String = "The Magician"
@export_multiline var text: String = "Message"

@export var tutorial_box: TutorialBox

func _execute():
	tutorial_box.set_data(actor_name, text)
