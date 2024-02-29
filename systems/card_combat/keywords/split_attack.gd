class_name SplitAttack
extends Keyword

func init():
	super.init()


func get_new_targets(target_offsets, attacker) -> Array[int]:
	return [-1, 1]
