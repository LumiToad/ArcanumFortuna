class_name TakeDamageSwitch
extends SwitchKeyword

@export_category("Condition")
## The Condition is met when this much attack damage was dealt by this card in total
@export var required_damage := 5
## If this is enabled all damage will be treated as 1 damage, meaning the times damage was taken are tracked instead of the amount
@export var ignore_damage_amount := true

var dealt_damage_lookup : Dictionary

func init():
	if title.count('%d') == 1:
		title = title % required_damage
	if description.count('%d') == 1:
		description = description % required_damage
	elif description.count('%d') == 2:
		description = description % [required_damage, required_damage]
	super.init()


func get_dynamic_description(owner: Card):
	return " (%d damage left.)" % (dealt_damage_lookup[owner] if owner in dealt_damage_lookup else required_damage)


func trigger(source, owner, target, icon_to_animate, params={}):
	if not ignore_damage_amount and not "taken_damage" in params:
		push_error("Damage Switch cannot be triggered without taken damage!")
		return
	await super(source, owner, target, icon_to_animate, params)
	if not owner in dealt_damage_lookup:
		dealt_damage_lookup[owner] = required_damage
	dealt_damage_lookup[owner] -= 1 if ignore_damage_amount else params["taken_damage"]
	if dealt_damage_lookup[owner] <= 0:
		await _on_completed(owner, icon_to_animate)
