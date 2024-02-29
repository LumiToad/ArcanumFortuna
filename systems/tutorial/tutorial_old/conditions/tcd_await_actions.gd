extends TutorialCondition

var completed = false

func _setup():
	setup_childs()


func setup_childs():
	for child in get_children():
		if child is TutorialAction:
			await child._execute()
	completed = true


func _completed() -> bool:
	return completed
