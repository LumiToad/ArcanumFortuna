extends TutorialAction

@export var card_battle: CardBattle

func _execute():
	var karma_phase = FriendlyKarmaPhase.new()
	karma_phase.init(card_battle)
	karma_phase.execute()
	await karma_phase.completed
