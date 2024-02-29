class_name TutorialStep
extends Node


func is_completed() -> bool:
	for node in get_children():
		if node is TutorialCondition:
			if not node._completed():
				return false
	return true


func setup_conditions() -> void:
	for node in get_children():
		if node is TutorialCondition:
			node._setup()


func do_actions() -> void:
	for node in get_children():
		if node is TutorialAction:
			node._execute()
