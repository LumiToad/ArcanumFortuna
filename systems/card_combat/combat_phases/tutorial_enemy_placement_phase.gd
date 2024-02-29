class_name TutorialEnemyPlacementPhase
extends CombatPhase

@export var card_data : Array[CardData] = [null, null, null, null, null]

static func get_class_name():
	return "Tutorial Enemy Placement Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_PLACEMENT


func process_effect() -> ExitState:
	var slot_idx = -1
	for card in card_data:
		slot_idx += 1
		if not card:
			continue
		combat.game_board.place_enemy_card_back(card, slot_idx)
		
	return ExitState.DEFAULT
