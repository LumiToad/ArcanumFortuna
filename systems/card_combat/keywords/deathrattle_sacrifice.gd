class_name DeathrattleSacrifice
extends ActivatedKeyword

@export var heal_amount := 3


func init():
	if title.count('%d') == 1:
		title = title % [heal_amount]
	if description.count('%d') == 1:
		description = description % [heal_amount]
	super.init()


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger DeathrattleSacrifice: Combat must be provided!")
		return null
	return combat.enemy if owner.is_enemy else combat.player


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not target.has_method("heal"):
		push_error("Cannot apply DeathrattleSacrifice: target '" + str(target) + "' has no heal method!")
		return
	target.heal(heal_amount)
