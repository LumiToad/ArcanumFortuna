extends TutorialCondition

@export var cooldown := 0.3

var running = false
var completed = false

signal cooldown_completed

func _setup():
	running = true


func setup_childs():
	for child in get_children():
		if child is TutorialCondition:
			child._setup()


func _completed() -> bool:
	if not completed:
		return false
	
	for node in get_children():
		if node is TutorialCondition:
			if not node._completed():
				return false
	return true


func _process(delta):
	if not running:
		return
	
	cooldown -= delta
	
	if cooldown <= 0:
		if not completed:
			completed = true
			cooldown_completed.emit()
			setup_childs()
			
