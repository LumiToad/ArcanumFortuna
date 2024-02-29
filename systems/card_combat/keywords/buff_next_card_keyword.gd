class_name BuffNextCardKeyword
extends ActivatedKeyword

@export var health_gain := 0
@export var attack_gain := 1

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


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger BuffNextCardKeyword: Combat must be provided!")
		return null
	return combat.enemy if owner.is_enemy else combat.player


func trigger(source, owner, target, icon_to_animate, params={}):
	target.try_add_stored_buff(Buff.new(attack_gain, health_gain, self, owner))
	await super(source, owner, target, icon_to_animate, params)
