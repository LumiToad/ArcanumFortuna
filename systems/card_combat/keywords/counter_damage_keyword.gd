class_name CounterDamageKeyword
extends ActivatedKeyword

## The amount of damage dealt to the attacker
@export var counter_damage := 1

func init():
	if title.count('%d') == 1:
		title = title % counter_damage
	if description.count('%d') == 1:
		description = description % counter_damage
	super.init()


func trigger(source, owner, target, icon_to_animate, params={}):
	if not source is CombatCard:
		push_error("[CounterDamage]: trigger failed due to invalid source")
		return
	await super(source, owner, target, icon_to_animate, params)
	await source.take_damage(counter_damage)
