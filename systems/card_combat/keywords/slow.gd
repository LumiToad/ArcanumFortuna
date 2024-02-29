class_name Slow
extends Keyword

@export var turns_to_skip = 1
@export var attack_on_first_turn = true
var turns_skipped_lookup : Dictionary = {}


func init():
	super.init()
	if title.count('%d') == 1:
		title = title % turns_to_skip
	if description.count('%d') == 1:
		description = description % turns_to_skip



func is_disabled(owner: Card):
	return turns_skipped_lookup[owner] <= turns_to_skip if owner in turns_skipped_lookup else not attack_on_first_turn


func get_dynamic_description(owner: Card):
	if not owner in turns_skipped_lookup and attack_on_first_turn:
		return ""
	var turns_left_to_skip = turns_to_skip - (turns_skipped_lookup[owner] if owner in turns_skipped_lookup else 0)
	if turns_left_to_skip == 0:
		return " (Is able to attack!)"
	return " (Can't attack for %d turns.)" % turns_left_to_skip

func get_new_targets(target_offsets, attacker) -> Array[int]:
	if not turns_skipped_lookup.has(attacker):
		turns_skipped_lookup[attacker] = turns_to_skip + 1 if attack_on_first_turn else 0
	turns_skipped_lookup[attacker] += 1
	if turns_skipped_lookup[attacker] <= turns_to_skip:
		await animate_keyword_particle(attacker)
		attacker.set_disabled_overlay_visible(false)
		return []
	turns_skipped_lookup[attacker] = 0
	return target_offsets
