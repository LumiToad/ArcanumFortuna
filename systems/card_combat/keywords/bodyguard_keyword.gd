class_name BodyguardKeyword
extends ActivatedKeyword

var combat_ref : CardBattle

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DeathrattleAtk: Combat must be provided!")
		return null
	combat_ref = combat
	return owner


func trigger(source, owner, target, icon_to_animate, params={}):
	if source.attack <= 0 or source.is_enemy == owner.is_enemy:
		return
	var allied_row = combat_ref.game_board.get_enemy_front_row() if owner.is_enemy \
			else combat_ref.game_board.get_friendly_row()
	if allied_row[params["target_column"]] != null:
		return
	await super(source, owner, target, icon_to_animate, params)
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered '%s'." % [owner.card_data.name, \
			 owner.tile_coordinate.x, owner.tile_coordinate.y, title])
	await combat_ref.game_board.try_move_card_sideways(owner.tile_coordinate.x, \
			params["target_column"], !owner.is_enemy)
	await source.get_tree().process_frame
