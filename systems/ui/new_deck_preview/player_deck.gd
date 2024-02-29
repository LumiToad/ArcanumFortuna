class_name PlayerDeckPreview
extends ScrollContainer

@export var hbox_template : PackedScene
@onready var vbox = %VBoxContainer

var hboxes : Array[DeckPreviewHBox]

func populate_with_cards(deck_cards):
	var card_amount = deck_cards.size()
	var hbox_amount = floori(card_amount / 5) + 1
	populate_hbox(hbox_amount)
	var i := 0
	for card in deck_cards:
		if not hboxes[i].try_add_card(card):
			i += 1
			hboxes[i].try_add_card(card)


func populate_hbox(amount : int):
	for i in range(0, amount + 1):
		var hbox = hbox_template.instantiate() as DeckPreviewHBox
		vbox.add_child(hbox)
		hboxes.append(hbox)


func clear():
	for hbox in hboxes:
		hbox.queue_free()
	hboxes.clear()
