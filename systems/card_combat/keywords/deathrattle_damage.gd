class_name DeathrattleDamage
extends ActivatedKeyword

@export var damage_amount := 3


func init():
	if title.count('%d') == 1:
		title = title % [damage_amount]
	if description.count('%d') == 1:
		description = description % [damage_amount]
	super.init()


func trigger(source, owner, target, icon_to_animate, params={}):
	if owner.health > 0:
		return
	await super(source, owner, target, icon_to_animate, params)
	await source.take_damage(damage_amount)
