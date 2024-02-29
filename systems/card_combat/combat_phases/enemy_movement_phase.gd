class_name EnemyMovementPhase
extends CombatPhase


static func get_class_name():
	return "Enemy Movement Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_MOVEMENT


func process_effect() -> ExitState:
	var back_row = combat.game_board.get_enemy_back_row()
	
	for i in range(back_row.size()):
		if back_row[i] != null:
			if await combat.game_board.try_move_enemy_card_to_front(i):
				combat.enemy.transfer_stored_buffs(back_row[i])
				await combat._on_card_played(back_row[i])
	return ExitState.DEFAULT
