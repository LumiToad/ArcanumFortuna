class_name EndPhase
extends CombatPhase


static func get_class_name():
	return "End Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.TURN_END
