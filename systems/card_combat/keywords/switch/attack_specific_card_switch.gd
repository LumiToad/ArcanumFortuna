class_name AttackSpecificCardSwitch
extends SwitchKeyword

enum ComparisonType {
	EQUAL,
	GREATER_THAN,
	GREATER_THAN_OR_EQUAL,
	LESSER_THAN,
	LESSER_THAN_OR_EQUAL
}

@export var comparison_type := ComparisonType.GREATER_THAN

func init():
	super.init()


func trigger(source, owner, target, icon_to_animate, params={}):
	if not source is CombatCard:
		return
	match comparison_type:
		ComparisonType.EQUAL:
			if source.attack == owner.attack:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.GREATER_THAN:
			if source.attack > owner.attack:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.GREATER_THAN_OR_EQUAL:
			if source.attack >= owner.attack:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.LESSER_THAN:
			if source.attack < owner.attack:
				await _on_completed(owner, icon_to_animate)
		ComparisonType.LESSER_THAN_OR_EQUAL:
			if source.attack <= owner.attack:
				await _on_completed(owner, icon_to_animate)
