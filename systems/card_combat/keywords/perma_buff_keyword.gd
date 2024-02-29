class_name PermaBuff
extends ActivatedKeyword

@export var health_gain : int = 1
@export var attack_gain : int = 0
## Determines how many tiles to the right and left are affected
@export var range := 1

func init():
	if title.count('%d') == 2:
		title = title % [attack_gain, health_gain]
	elif title.count('%d') == 1:
		title = title % (attack_gain if health_gain == 0 else health_gain)

	if description.count('%d') == 2:
		description = description % [attack_gain, health_gain]
	elif description.count('%d') == 1:
		description = description % (attack_gain if health_gain == 0 else health_gain)
	super.init()

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger PermaBuff: Combat must be provided!")
		return
	var targets : Array[CombatCard] = []
	var cards = combat.game_board.get_front_enemies() if owner.is_enemy \
			else combat.game_board.get_friendly_cards()
	for i in range(cards.size()):
		if cards[i] != owner:
			continue
		for j in range(1, range + 1):
			if i - j >= 0 && cards[i-j] != null:
				targets.append(cards[i-j])
			if i + j < cards.size() && cards[i+j] != null:
				targets.append(cards[i+j])
		break
	return targets


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if target == null:
		return
	for card in target:
		card.try_add_buff(Buff.new(attack_gain, health_gain, self, owner))
