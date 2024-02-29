class_name  PlayerHpSwitch
extends SwitchKeyword

@export var min_hp := 10

func init():
	if title.count('%d') == 1:
		title = title % min_hp
	if description.count('%d') == 1:
		description = description % min_hp
	elif description.count('%d') == 2:
		description = description % [min_hp, min_hp]
	super.init()

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger PlayerHpSwitch: Combat must be provided!")
		return []
	return combat.enemy if  owner.is_enemy \
			else combat.player

func trigger(source, owner, target, icon_to_animate, params={}):
	if not target is EnemyPlayer and not target is CardPlayer:
		push_error("PlayerHpSwitch triggered with invalid target: ", target)
		return
	
	if target.health <= min_hp:
		await _on_completed(owner, icon_to_animate)
