extends TutorialAction

@export var card_to_draw: CardData
@export var card_player: CardPlayer

func _execute():
	if card_to_draw != null:
		card_player.card_stack.put_card_in_stack(card_to_draw)
	await card_player.draw_card()

	card_player.set_active(true)
