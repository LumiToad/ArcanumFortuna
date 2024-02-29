class_name CombatPhaseTrigger
extends Resource

enum SourcePhases {
	NONE,
	TURN_START, 
	FRIENDLY_PLACEMENT,
	FRIENDLY_ATTACKS, 
	FRIENDLY_KARMA,
	ENEMY_MOVEMENT,
	ENEMY_PLACEMENT,
	ENEMY_ATTACKS,
	ENEMY_KARMA,
	TURN_END,
	TUTORIAL_PHASE,
}

enum Timings {
	STARTED,
	FINISHED,
}

@export var source_phase := SourcePhases.TURN_START
@export var timing := Timings.STARTED
