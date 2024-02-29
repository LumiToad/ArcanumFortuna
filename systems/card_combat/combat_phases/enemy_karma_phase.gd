class_name EnemyKarmaPhase
extends FriendlyKarmaPhase

static func get_class_name():
	return "Enemy Karma Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.ENEMY_KARMA

func get_relevant_cards():
	return combat.game_board.get_front_enemies().filter(
			func(card: Card):
				return card.cost != 0
				)

func get_karma_modify_target():
	return combat.enemy
