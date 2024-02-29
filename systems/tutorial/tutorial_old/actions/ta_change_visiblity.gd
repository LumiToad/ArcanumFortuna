extends TutorialAction

@export var nodes: Array[Node]
@export var new_status: bool = true

func _execute():
	for node in nodes:
		if "visible" in node:
			node.visible = new_status
