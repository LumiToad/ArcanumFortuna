class_name CardsPlayedSwitch
extends SwitchKeyword

## The Condition is met when the keyword was triggerd this often
@export var played_cards_count := 1
@export var require_allied_cards := true

var played_count_lookup : Dictionary


func init():
	if triggers != ActivatedKeyword.Triggers.ON_ACTIVE_CARDS_CHANGED or combat_phase_triggers.size() != 0:
		push_error("CardsPlayedSwitch can only be used with 'On Played' trigger. Set triggers were discarded.")
		triggers = ActivatedKeyword.Triggers.ON_ACTIVE_CARDS_CHANGED
		combat_phase_triggers.clear()

	if title.count('%d') == 1:
		title = title % played_cards_count
	if description.count('%d') == 1:
		description = description % played_cards_count
	elif description.count('%d') == 2:
		description = description % [played_cards_count, played_cards_count]
	super.init()

func get_dynamic_description(owner: Card):
	return " (%d cards left.)" % (played_count_lookup[owner] if owner in played_count_lookup else played_cards_count)

func trigger(source, owner, target, icon_to_animate, params={}):
	if not source is CombatCard:
		return
	if source == owner or (require_allied_cards and source.is_enemy != owner.is_enemy):
		return

	await super(source, owner, target, icon_to_animate, params)
	if not owner in played_count_lookup:
		played_count_lookup[owner] = max(1, played_cards_count)
	played_count_lookup[owner] -= 1
	if played_count_lookup[owner] == 0:
		await _on_completed(owner, icon_to_animate)
