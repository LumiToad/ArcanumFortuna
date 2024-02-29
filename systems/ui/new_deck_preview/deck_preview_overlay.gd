class_name DeckPreviewOverlay
extends UIBase

@export var deck_card_template : PackedScene
@export var is_selectable = false

var previous_current_window
var player_data : PlayerData
var card_data_lookup = {}
var select_button
var selected_cards_amount := 0

@onready var animation_player = %AnimationPlayer
@onready var player_deck : PlayerDeckPreview = %PlayerDeck


func setup():
	select_button = %SelectCardsToBurnShopButton
	animation_player.play("open_deck_preview")
	player_data = Player.instance.data
	get_cards()
	sort_karma()
	%SortByKarmaButton.grab_focus()
	select_button.disabled = !is_selectable
	select_button.visible = is_selectable
	for node in SceneHandler.ui_container.get_children():
		if node is UIBase:
			if node.get_layer() < get_layer():
				previous_current_window = node
				previous_current_window.is_current_window = false
				is_current_window = true
	select_button.disabled = true
	for card in get_all_nodes(self):
		if card is DeckPreviewCard:
			card.select_card.clicked.connect(on_card_clicked)


func get_cards():
	self.card_data_lookup.clear()
	for card_data in player_data.cardStack:
		var filtered_keys = card_data_lookup.keys().filter(func (x): return x.name == card_data.name)
		
		if filtered_keys.size() >= 1:
			card_data_lookup[filtered_keys[0]] += 1
		else:
			card_data_lookup[card_data] = 1


func get_deck_preview_cards():
	var deck_cards : Array[DeckPreviewCard]
	for card_data in card_data_lookup.keys():
		var deck_card_instance = deck_card_template.instantiate() as DeckPreviewCard
		deck_card_instance.setup(card_data, card_data_lookup[card_data], is_selectable)
		deck_cards.append(deck_card_instance)
	return deck_cards


func clear():
	player_deck.clear()
	card_data_lookup.clear()
	get_cards()


func sort_karma():
	clear()
	var deck_cards = get_deck_preview_cards()
	card_data_lookup.keys()
	deck_cards.sort_custom(
		func(a, b): return a.select_card.card_data.cost > b.select_card.card_data.cost
	)
	player_deck.populate_with_cards(deck_cards)


func sort_attack():
	clear()
	var deck_cards = get_deck_preview_cards()
	deck_cards.sort_custom(
		func(a, b): return a.select_card.card_data.attack > b.select_card.card_data.attack
	)
	player_deck.populate_with_cards(deck_cards)


func sort_health():
	clear()
	var deck_cards = get_deck_preview_cards()
	deck_cards.sort_custom(
		func(a, b): return a.select_card.card_data.health > b.select_card.card_data.health
	)
	player_deck.populate_with_cards(deck_cards)


func close():
	animation_player.play("close_deck_preview")
	await animation_player.animation_finished
	if previous_current_window != null:
		previous_current_window.is_current_window = false
	super.close()


func get_all_nodes(node):
	var array : Array
	
	if node.get_child_count() > 0:
		for found_node in node.get_children():
			array.append_array(get_all_nodes(found_node))
			array.append(found_node)
		return array
	return array


func on_card_clicked(select_card : SelectCard):
	selected_cards_amount += 1 if select_card.selected else -1
	select_button.disabled = selected_cards_amount == 0


func _on_close_window_button_button_up():
	close()


func _on_sort_by_karma_button_button_up():
	sort_karma()


func _on_sort_by_attack_button_button_up():
	sort_attack()


func _on_sort_by_health_button_button_up():
	sort_health()


func _on_select_cards_to_burn_shop_button_button_up():
	var cards : Array[CardData]
	
	for card in get_all_nodes(self):
		if card is DeckPreviewCard and card.is_selected():
			cards.append(card.select_card.card_data)
	
	if player_data.cardStack.size() - cards.size() < 3:
		return

	if called_by.has_method("receive_result"):
		if cards.size() > 0:
			called_by.receive_result(cards)
	close()


func _on_background_gui_input(event : InputEvent):
	if event.is_action_released("pickUpCard") or event.is_action_released("open_inspection"):
		close()
