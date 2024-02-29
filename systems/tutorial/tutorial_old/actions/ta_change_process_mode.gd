extends TutorialAction

@export var nodes: Array[Node]
@export var new_status: Node.ProcessMode = 0

func _execute():
	for node in nodes:
		node.process_mode = new_status
