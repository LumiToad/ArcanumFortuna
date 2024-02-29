class_name shield
extends Keyword


## Factor by which the damage is reduced. 1.0 means 100% of damage is blocked, 0.0 means no damage is blocked.
@export var damage_reduction := 1.0
## This fixed number will be substracted from the dealt damage in addition to the damage reduction factor
@export var fixed_damage_reduction := 0

## Damage reduction will only be apllied while uses are available. Setting it to < 0 will enabled unlimited uses.
@export var uses := 1

var user_lookup : Dictionary = {}

func init():
	if title.count("%d") == 1:
		title = title % (int(damage_reduction * 100) if fixed_damage_reduction == 0 else fixed_damage_reduction)
	if description.count("%d") == 1:
		description = description % (int(damage_reduction * 100) if fixed_damage_reduction == 0 else fixed_damage_reduction)

func get_reduced_damage(owner, damage):
	if uses < 0:
		return max(0, damage - damage * damage_reduction - fixed_damage_reduction)
	if not user_lookup.has(owner):
		user_lookup[owner] = uses
	if user_lookup[owner] <= 0 or damage == 0:
		return damage
	user_lookup[owner] -= 1
	if user_lookup[owner] <= 0:
		var to_remove : Array[Keyword] = [self]
		owner.modify_keywords(to_remove)
	return max(0, damage - damage * damage_reduction - fixed_damage_reduction)
