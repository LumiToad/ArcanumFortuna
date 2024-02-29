extends TutorialAction

@export var card_battle: CardBattle
@export var phases : Array[CombatPhase]


func _execute():
	card_battle.game_board.lock_friendly_cards(card_battle)
	await get_tree().process_frame
	for phase in phases:
		phase.init(card_battle)
		phase.execute()
		await phase.completed
