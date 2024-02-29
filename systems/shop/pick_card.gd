class_name CardPick
extends Node

signal card_picked(card: CardData)

@export var card_template: PackedScene


func prompt_for_card(potential_cards: Array[CardData]) -> CardData:
	for card in potential_cards:
		var c = card_template.instantiate() as SelectCard
		c.load_from_data(card)
		c.setup()
		add_child(c)
		c.global_position = Vector2(1920/2 - 105, 0)
		c.clicked.connect(card_clicked)
		c.reparent(%Hand)
	var result = await card_picked
	queue_free()
	return result

func card_clicked(card: SelectCard):
	card_picked.emit(card.card_data)
