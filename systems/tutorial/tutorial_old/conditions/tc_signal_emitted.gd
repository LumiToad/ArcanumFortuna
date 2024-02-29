extends TutorialCondition

@export var node_with_signal: Node
@export var signal_name: String

var emitted := false


func _setup():
	node_with_signal.connect(signal_name, complete)


func _completed() -> bool:
	return emitted


func complete():
	emitted = true
