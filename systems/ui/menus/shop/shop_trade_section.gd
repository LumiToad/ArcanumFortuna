class_name ShopTradeSection
extends UITabBase

@export var all_cards_resource : AllCards
@export var cost_label : Label
@export var shop_card_1 : ShopPreviewCard
@export var shop_card_2 : ShopPreviewCard
@export var shop_card_3 : ShopPreviewCard
@export var hand_card_1 : ShopPreviewCard
@export var hand_card_2 : ShopPreviewCard
@export var hand_card_3 : ShopPreviewCard
@export var card_prize := 3

var player_data : PlayerData
var trade_button
var original_price_text : String

func setup():
	trade_button = $TradeButton
	cost_label = $TradeButton/Label
	original_price_text = cost_label.text
	reset_button()
	player_data = Player.instance.data
	randomize_shop_cards()
	randomize_hand_cards()
	hand_card_1.selected_shader.color = Color.DARK_BLUE
	hand_card_2.selected_shader.color = Color.DARK_BLUE
	hand_card_3.selected_shader.color = Color.DARK_BLUE
	set_trade_button_enabled()


func randomize_shop_cards():
	randomize()
	var possible_cards = all_cards_resource.all_cards
	
	shop_card_1.card_data = get_random_by_seed(possible_cards, called_by.rng)
	shop_card_2.card_data = get_random_by_seed(possible_cards, called_by.rng)
	shop_card_3.card_data = get_random_by_seed(possible_cards, called_by.rng)


func randomize_hand_cards():
	var card_stack = player_data.cardStack.duplicate()
	var card = get_random_by_seed(card_stack, called_by.rng)
	hand_card_1.card_data = card.duplicate()
	card_stack.erase(card)
	card = get_random_by_seed(card_stack, called_by.rng)
	hand_card_2.card_data = card.duplicate()
	card_stack.erase(card)
	card = get_random_by_seed(card_stack, called_by.rng)
	hand_card_3.card_data = card.duplicate()
	card_stack.erase(card)


func get_random_by_seed(array, rng):
	var random_elem = array[rng.randi() % array.size()]
	return random_elem


func process_trade():
	trade_button.disabled = true
	SfxOther._SFX_Money()
	
	var s_cards : Array[ShopPreviewCard] = get_shop_cards()
	var h_cards : Array[ShopPreviewCard] = get_hand_cards()
	var tree = SceneHandler.current_scene.get_tree()
	var deck
	for node in SceneHandler.ui_container.get_children():
		if node is DeckInMenu:
			deck = node.get_child(0).get_child(0)
	
	for s_card in s_cards:
		player_data.cardStack.append(s_card.card_data)
	for s_card in s_cards:
		await called_by.card_to_deck_animation(s_card)
		s_card.visible = false
		s_card.selected = false
	for h_card in h_cards:
		erase_card_from_player(h_card.card_data)
	for h_card in h_cards:
		h_card.selected_shader.visible = false
		await h_card.animate_burn()
		h_card.visible = false
		h_card.selected = false
	reset_button()


func erase_card_from_player(card_data : CardData):
	for card in player_data.cardStack:
		if card.name == card_data.name and card.attack == card_data.attack:
			player_data.cardStack.erase(card)
			return


func get_shop_cards():
	var s_cards : Array[ShopPreviewCard]
	
	if shop_card_1 != null and shop_card_1.selected == true:
		s_cards.append(shop_card_1)
	if shop_card_2 != null and shop_card_2.selected == true:
		s_cards.append(shop_card_2)
	if shop_card_3 != null and shop_card_3.selected == true:
		s_cards.append(shop_card_3)
	
	return s_cards


func get_hand_cards():
	var h_cards : Array[ShopPreviewCard]
	
	if hand_card_1 != null and hand_card_1.selected == true:
		h_cards.append(hand_card_1)
	if hand_card_2 != null and hand_card_2.selected == true:
		h_cards.append(hand_card_2)
	if hand_card_3 != null and hand_card_3.selected == true:
		h_cards.append(hand_card_3)
	
	return h_cards


func is_card_count_matched():
	return get_selected_shop_card_count() == get_selected_hand_card_count()


func reset_button():
	set_label_gold(0)
	trade_button.disabled = true


func get_selected_shop_card_count():
	var shop_count := 0
	for card in get_shop_cards():
		if card.selected:
			shop_count += 1
	return shop_count


func get_selected_hand_card_count():
	var hand_count := 0
	for card in get_hand_cards():
		if card.selected:
			hand_count += 1
	return hand_count


func set_trade_button_enabled():
	await SceneHandler.scene_container.get_tree().process_frame
	
	if get_selected_shop_card_count() == 0:
		trade_button.disabled = true
		return
	if is_card_count_matched() == false:
		trade_button.disabled = true
		return
	if get_selected_shop_card_count() * card_prize > player_data.currency:
		trade_button.disabled = true
		return
	trade_button.disabled = false


func set_label_gold(amount : int):
	cost_label.text = original_price_text
	cost_label.text = cost_label.text.replace("[amount]", str(amount))


func disable_lost_cards():
	var missing_one := false
	for card_data in player_data.cardStack:
		missing_one = card_data.name != hand_card_1.card_data.name
		if not missing_one:
			break
	var missing_two := false
	for card_data in player_data.cardStack:
		missing_two = card_data.name != hand_card_2.card_data.name
		if not missing_two:
			break
	var missing_three := false
	for card_data in player_data.cardStack:
		missing_three = card_data.name != hand_card_3.card_data.name
		if not missing_three:
			break
	if missing_one:
		hand_card_1.selected = false
		hand_card_1.visible = false
	if missing_two:
		hand_card_2.selected = false
		hand_card_2.visible = false
	if missing_three:
		hand_card_3.selected = false
		hand_card_3.visible = false


func _on_shop_card_clicked():
	set_trade_button_enabled()
	await get_tree().process_frame
	set_label_gold(get_selected_shop_card_count() * card_prize)


func _on_hand_card_clicked():
	set_trade_button_enabled()


func _on_trade_button_button_up():
	process_trade()


func _on_visibility_changed():
	if visible:
		await get_tree().process_frame
		disable_lost_cards()
		set_trade_button_enabled()
		set_label_gold(get_selected_shop_card_count() * card_prize)
