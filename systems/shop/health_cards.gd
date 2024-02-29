extends Node

@export var card_template: PackedScene
## Should be at least as many as slots for healing cards available.
## If more than slots values are used random values will be picked.
@export var potential_values : Array[HealingValue]

## Should the card be removed after being purchased?
@export var remove_card_after_purchase := true
## Should only one card be purchased in total?
@export var can_only_buy_one := true


var player_data_ref: PlayerData


func _process(delta):
	for slot in $Cards.get_children():
		if slot.get_child_count() > 0:
			slot.get_child(0).can_afford(player_data_ref.currency)


func setup(rng: RandomNumberGenerator, player_data: PlayerData):
	player_data_ref = player_data
	var grabbag = potential_values.duplicate()
	var chosen_cards = []
	
	for card in range(min(len(grabbag), $Cards.get_child_count())):
		var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
		chosen_cards.append(c)
	
	chosen_cards.sort_custom(func(a, b): return a.healing_amount < b.healing_amount)
	
	for i in range(min(len(chosen_cards), $Cards.get_child_count())):
		var c = chosen_cards[i]
		var slot = $Cards.get_child(i)
		var instance = card_template.instantiate() as HealingCard
		instance.set_value(c.healing_amount, c.costs)
		instance.clicked.connect(card_clicked)
		slot.add_child(instance)


func card_clicked(health_card: HealingCard):
	if not health_card.affordable:
		return
	
	player_data_ref.currency -= health_card.costs
	player_data_ref.health += health_card.healing_amount
	health_card.queue_free()
	if can_only_buy_one:
		clean_up()


func clean_up():
	for slot in $Cards.get_children():
		if slot.get_child_count() > 0:
			slot.get_child(0).queue_free()
