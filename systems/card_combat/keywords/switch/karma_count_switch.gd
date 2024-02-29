class_name KarmaCountSwitch
extends SwitchKeyword

enum ComparisonType {
	EQUAL,
	GREATER_THAN,
	GREATER_THAN_OR_EQUAL,
	LESSER_THAN,
	LESSER_THAN_OR_EQUAL
}

@export var target_karma_count := 3
@export var comparison_type := ComparisonType.LESSER_THAN_OR_EQUAL


func init():
	if title.count('%d') == 1:
		title = title % target_karma_count
	if description.count('%d') == 1:
		description = description % target_karma_count
	elif description.count('%d') == 2:
		description = description % [target_karma_count, target_karma_count]
	super.init()


func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger KarmaCountSwitch: Combat must be provided!")
		return null
	return combat.enemy if owner.is_enemy else combat.player


func trigger(source, owner, target, icon_to_animate, params={}):
	match comparison_type:
		ComparisonType.EQUAL:
			if target.karma == target_karma_count:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.GREATER_THAN:
			if target.karma > target_karma_count:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.GREATER_THAN_OR_EQUAL:
			if target.karma >= target_karma_count:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.LESSER_THAN:
			if target.karma < target_karma_count:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.LESSER_THAN_OR_EQUAL:
			if target.karma <= target_karma_count:
				await _on_completed(owner, icon_to_animate)
