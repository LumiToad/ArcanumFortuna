extends TutorialCondition

@export var action: String
@export var cooldown := 0.0

var executed := false
var can_execute := false

func _setup():
	if cooldown > 0:
		await get_tree().create_timer(cooldown).timeout
	can_execute = true


func _completed() -> bool:
	return executed


func _input(event: InputEvent):
	if can_execute:
		if event.is_action(action):
			executed = true
