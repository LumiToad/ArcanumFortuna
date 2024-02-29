extends TutorialAction

@export var card_battle: CardBattle

func _execute():
	for i in range(5):
		await card_battle.game_board.try_move_enemy_card_to_front(i)
	var attack_phase = EnemyAttackPhase.new()
	attack_phase.init(card_battle)
	attack_phase.execute()
	await attack_phase.completed

