class_name DeckPreviewCard
extends Control

var counter : Control
var label : Label
var select_card : SelectCard

func setup(card_data, amount, is_selectable):
	label = %CopyCounterLabel
	select_card = %SelectCard
	counter = %CopyCounter
	counter.visible = amount != 1
	label.text = str(amount)
	select_card.card_data = card_data
	select_card.is_selectable = is_selectable


func is_selected():
	return select_card.selected
