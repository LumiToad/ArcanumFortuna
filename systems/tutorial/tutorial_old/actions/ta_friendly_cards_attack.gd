extends TutorialAction

@export var card_battle: CardBattle

func _execute():
	card_battle.game_board.lock_friendly_cards(card_battle)
	await get_tree().process_frame
	var phase = FriendlyAttackPhase.new()
	phase.init(card_battle)
	phase.execute()
	await phase.completed
