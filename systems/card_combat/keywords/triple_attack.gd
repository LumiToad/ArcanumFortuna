class_name TripleAttack
extends Keyword

var turns_to_skip = 1

func init():
	super.init()

func get_new_targets(target_offsets, attacker) -> Array[int]:
	return [-1, 0, 1]
