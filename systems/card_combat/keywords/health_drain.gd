class_name HealthDrain
extends ActivatedKeyword

@export var health_gain = 1

## If this is enabled only cards on the same side as the card containing this keyword will be considered for the buff
@export var scale_from_same_side_only = false
@export var enable_debug_print = false

var previous_health_gained := 0
var buff_lookup : Dictionary = {}

func init():
	if description.count('%d') == 1:
		description = description % health_gain
	super.init()


func get_dynamic_description(owner: Card):
	if not owner in buff_lookup:
		return ""
	return " (%d)" % (buff_lookup[owner].health_gain / health_gain)


func trigger(source, owner, target, icon_to_animate, params={}):
	if owner.health <= 0:
		return
	await super(source, owner, target, icon_to_animate, params)
	if not target is CombatCard:
		push_error("Cannot apply HealthDrain. Invalid target ", target, ".")
		return
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered Healthdrain." % [target.card_data.name, target.tile_coordinate.x, target.tile_coordinate.y])
	if enable_debug_print:
		print("Health Drain triggered on ", target.card_name)
	var hit_count = 0
	if not buff_lookup.has(owner):
		buff_lookup[owner] = Buff.new(0, health_gain, self, owner)
	else:
		target.try_remove_buff(buff_lookup[owner])
	for card : CombatCard in params.active_cards:
		if enable_debug_print:
			print("Card '" + card.card_name + "' costs " + str(card.cost))
		if card.cost > 0 and (!scale_from_same_side_only or card.is_enemy == owner.is_enemy):
			hit_count += 1
	target.try_add_buff(buff_lookup[owner])
