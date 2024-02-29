class_name StartPhase
extends CombatPhase

var was_already_invoked = false

@export var place_enemy_cards_before_first_turn = true

static func get_class_name():
	return "Start Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.TURN_START


func process_effect() -> ExitState:
	if not was_already_invoked:
		if place_enemy_cards_before_first_turn:
			var enemy_placement_phase = EnemyPlacementPhase.new()
			enemy_placement_phase.init(combat)
			enemy_placement_phase.execute()
			await enemy_placement_phase.completed
		for i in range(combat.player_data.start_hand_size):
			await combat.player.draw_card()
		was_already_invoked = true
		return ExitState.DEFAULT
	for i in range(combat.player_data.draw_amount):
		await combat.player.draw_card()
	return ExitState.DEFAULT


func reset():
	was_already_invoked = false
