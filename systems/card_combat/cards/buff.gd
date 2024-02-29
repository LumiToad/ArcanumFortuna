class_name Buff
extends Resource

@export var health_gain := 0
@export var attack_gain := 0

@export var created_by : Keyword
@export var owner_name : String = ""


func _init(attack_diff = attack_gain, health_diff = health_gain, \
		creator : Keyword = null, owner : Card = null):
	health_gain = health_diff
	attack_gain = attack_diff
	created_by = creator
	if owner:
		owner_name = owner.card_name

func get_owner_name():
	return owner_name
	
	
func get_creator_name():
	return created_by.title if created_by else ""
	

func add_stats(to : Card):
	if health_gain != 0:
		to.health = max(1, to.health + health_gain)
	to.attack += attack_gain


func remove_stats(from : Card):
	if health_gain != 0:
		from.health = max(1, from.health - health_gain)
	from.attack -= attack_gain
