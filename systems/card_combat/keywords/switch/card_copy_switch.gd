class_name CardCopySwitch
extends SwitchKeyword

@export var required_card_count := 3
var current_card_count := 0

func init():
	if title.count('%d') == 1:
		title = title % required_card_count
	if description.count('%d') == 1:
		description = description % required_card_count
	elif description.count('%d') == 2:
		description = description % [required_card_count, required_card_count]
	super.init()


func get_dynamic_description(owner: Card):
	return " (%d cards left.)" % (current_card_count - required_card_count)

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger CardCopySwitch: Combat must be provided!")
		return []
	return combat.game_board.get_front_enemies() if owner.is_enemy \
			else combat.game_board.get_friendly_cards()


func trigger(source, owner, target, icon_to_animate, params={}):
	var hit_count = 0
	for card : CombatCard in target:
		if card.card_name != owner.card_name:
			continue
		hit_count += 1
	current_card_count = hit_count
	if hit_count >= required_card_count:
		await _on_completed(owner, icon_to_animate)
