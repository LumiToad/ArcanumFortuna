class_name DamageSwitch
extends SwitchKeyword


enum DamageType {
	CARDS_ONLY,
	PLAYER_ONLY,
	ALL
}

@export_category("Condition")
## The Condition is met when this much attack damage was dealt by this card in total
@export var required_damage := 5
@export var damage_to_track := DamageType.ALL

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
	if not "damage_dealt" in params:
		push_error("Damage Switch cannot be triggered without dealt damage!")
		return
	if damage_to_track == DamageType.CARDS_ONLY and not source is CombatCard:
		return
	if damage_to_track == DamageType.PLAYER_ONLY and not source is Player and not source is EnemyPlayer:
		return
	await super(source, owner, target, icon_to_animate, params)
	if not owner in dealt_damage_lookup:
		dealt_damage_lookup[owner] = required_damage
	dealt_damage_lookup[owner] -= params["damage_dealt"]
	if dealt_damage_lookup[owner] <= 0:
		await _on_completed(owner, icon_to_animate)
	
