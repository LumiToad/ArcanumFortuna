extends TutorialCondition


@export var card_player: CardPlayer


func _completed() -> bool:
	return card_player.hand.get_child_count() == 0
