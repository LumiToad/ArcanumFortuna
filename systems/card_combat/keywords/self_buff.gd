class_name SelfBuff
extends ActivatedKeyword

@export var health_gain : int = 0
@export var attack_gain : int = 1

var buff_lookup := {}

func init():
	if title.count('%d') == 2:
		title = title % [attack_gain, health_gain]
	elif title.count('%d') == 1:
		title = title % (attack_gain if health_gain == 0 else health_gain)

	if description.count('%d') == 2:
		description = description % [attack_gain, health_gain]
	elif description.count('%d') == 1:
		description = description % (attack_gain if health_gain == 0 else health_gain)
	super.init()


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not owner is CombatCard:
		push_error("Cannot apply Self-Buff. Invalid target ", owner, ".")
		return
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered self_buff." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y])
	
	if not buff_lookup.has(owner):
		buff_lookup[owner] = Buff.new(attack_gain, health_gain, self, owner)
	else:
		owner.try_remove_buff(buff_lookup[owner])
		buff_lookup[owner].attack_gain += attack_gain
		buff_lookup[owner].health_gain += health_gain
	owner.try_add_buff(buff_lookup[owner])
