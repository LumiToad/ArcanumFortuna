class_name CombatPhase
extends Resource

signal completed(exit_state : ExitState)

enum ExitState {
	DEFAULT,
	ABORT
}

var combat : CardBattle

func init(combat : CardBattle):
	self.combat = combat


#region override functions

static func get_class_name():
	return "Undefined"

func get_corresponding_trigger() -> CombatPhaseTrigger.SourcePhases:
	return CombatPhaseTrigger.SourcePhases.NONE


func process_effect() -> ExitState:
	return ExitState.DEFAULT


func reset():
	pass


func execute():
	GlobalLog.add_entry(get_class_name() + " started.")
	await process_start_keywords(self, combat.game_board.get_active_cards())
	var exit_state = await process_effect()
	await process_end_keywords(self, combat.game_board.get_active_cards())
	await Engine.get_main_loop().process_frame
	completed.emit(exit_state)
	GlobalLog.add_entry(get_class_name() + " finished.")

#endregion


func process_start_keywords(trigger_source, applicable_cards : Array[CombatCard]):
	for card : CombatCard in applicable_cards:
		for i in range(card.keywords.size()):
			if not card.keywords[i] is ActivatedKeyword:
				continue
			for trigger : CombatPhaseTrigger in card.keywords[i].combat_phase_triggers:
				if trigger.timing != CombatPhaseTrigger.Timings.STARTED:
					continue
				if trigger.source_phase != get_corresponding_trigger():
					continue
				await card.keywords[i].trigger(self, card, card.keywords[i].get_target(self, card, combat), \
						card.get_node("KeyWordSlots").get_child(i).get_child(0))
				if combat.is_blocked:
					await combat.block_lifted


func process_end_keywords(trigger_source, applicable_cards : Array[CombatCard]):
	for card : CombatCard in applicable_cards:
		for i in range(card.keywords.size()):
			if not card.keywords[i] is ActivatedKeyword:
				continue
			for trigger : CombatPhaseTrigger in card.keywords[i].combat_phase_triggers:
				if trigger.timing != CombatPhaseTrigger.Timings.FINISHED:
					continue
				if trigger.source_phase != get_corresponding_trigger():
					continue
				await card.keywords[i].trigger(self, card,  card.keywords[i].get_target(self, card, combat), \
						 card.get_node("KeyWordSlots").get_child(i).get_child(0))
				if combat.is_blocked:
					await combat.block_lifted
