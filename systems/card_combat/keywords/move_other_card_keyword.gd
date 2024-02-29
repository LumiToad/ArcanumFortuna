class_name MoveOtherCardKeyword
extends ActivatedKeyword

enum TargetType {
	LOWEST_HEALTH_ENEMY,
}

@export var target_type = TargetType.LOWEST_HEALTH_ENEMY

var combat_ref : CardBattle

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DeathrattleAtk: Combat must be provided!")
		return null
	combat_ref = combat
	var opposing_card = combat.game_board.get_front_enemies() if not owner.is_enemy \
			else combat.game_board.get_friendly_cards()
	match target_type:
		TargetType.LOWEST_HEALTH_ENEMY:
			return get_lowest_attack_target(opposing_card) 
		_:
			return null


func get_lowest_attack_target(opposing_cards):
	var lowest_attack = INF
	var target = null
	for card : CombatCard in opposing_cards:
		if card.attack < lowest_attack:
			target = card
	return target


func trigger(source, owner, target, icon_to_animate, params={}):
	if target == null:
		return
	await super(source, owner, target, icon_to_animate, params)
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered '%s'." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y, title])
	await combat_ref.game_board.try_move_card_sideways(target.tile_coordinate.x, owner.tile_coordinate.x, !target.is_enemy)
