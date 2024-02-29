class_name LifestealKeyword
extends ActivatedKeyword

var buff_lookup : Dictionary = {}

func get_dynamic_description(owner: Card):
	if not owner in buff_lookup:
		return ""
	return " (Gained Health: %d)" % buff_lookup[owner].health_gain


func trigger(source, owner, target, icon_to_animate, params={}):
	if not "damage_dealt" in params:
		push_error("Damage Switch cannot be triggered without dealt damage!")
		return
	await super(source, owner, target, icon_to_animate, params)
	if not buff_lookup.has(owner):
		buff_lookup[owner] = Buff.new(0, 0, self, owner)
	else:
		owner.try_remove_buff(buff_lookup[owner])
	buff_lookup[owner].health_gain += params["damage_dealt"]
	owner.try_add_buff(buff_lookup[owner])
