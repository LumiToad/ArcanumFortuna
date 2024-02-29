class_name ATK_Drain
extends ActivatedKeyword

@export var attack_gain = 1

## If this is enabled only cards on the same side as the card containing this keyword will be considered for the buff
@export var scale_from_same_side_only = false
@export var enable_debug_print = false

var buff_lookup : Dictionary = {}

func init():
	if description.count('%d') == 1:
		description = description % attack_gain
	super.init()


func get_dynamic_description(owner: Card):
	if not owner in buff_lookup:
		return ""
	return " (%d)" % (buff_lookup[owner].attack_gain / attack_gain)


func trigger(source, owner, target, icon_to_animate, params={}):
	if not "active_cards" in params or owner.health <= 0:
		return
	await super(source, owner, target, icon_to_animate, params)
	if not target is CombatCard:
		push_error("Cannot apply ATKDrain. Invalid target ", target, ".")
		return
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered ATKdrain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	if not buff_lookup.has(owner):
		buff_lookup[owner] = Buff.new(0, 0, self, owner)
	target.try_remove_buff(buff_lookup[owner])
	var hit_count = 0
	for card : CombatCard in params.active_cards:
		if card.cost > 0 and (!scale_from_same_side_only or card.is_enemy == owner.is_enemy):
			hit_count += 1
	buff_lookup[owner].attack_gain = hit_count * attack_gain
	target.try_add_buff(buff_lookup[owner])
