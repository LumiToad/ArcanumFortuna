class_name GrantKeywordsKeyword
extends ActivatedKeyword

## The keywords that will be given to the target cards
@export var keywords_to_grant : Array[Keyword]
## Determines how many tiles to the right and left are affected
@export var range := 1
@export var remove_keywords_on_death := true
var buffed_cards_lookup : Dictionary = {}
var empty_array : Array[Keyword]

func get_target(source, owner, combat = null):
	if combat == null:
		push_error("Cannot trigger PermaBuff: Combat must be provided!")
		return []
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
	GlobalLog.add_entry("Card '%s' at position %d-%d triggered Companionship Health." % [owner.card_data.name, owner.tile_coordinate.x, owner.tile_coordinate.y])
	
	if not buffed_cards_lookup.has(owner):
		buffed_cards_lookup[owner] = []
	
	if remove_keywords_on_death and owner.health <= 0:
		print("[Keyword] Card " + str(owner) + " died and removed their Companionship Health.")
		for card in buffed_cards_lookup[owner]:
			if is_instance_valid(card):
				card.modify_keywords(keywords_to_grant, empty_array)
		return
	for card : CombatCard in target:
		if not card in buffed_cards_lookup[owner]:
			card.modify_keywords(empty_array, keywords_to_grant)
	buffed_cards_lookup[owner] = target
