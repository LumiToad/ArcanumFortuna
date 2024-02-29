class_name ShopBuySection
extends UITabBase

@export var all_cards_resource : AllCards
@export var cost_label : Label
@export var shop_card_1 : ShopPreviewCard
@export var shop_card_2 : ShopPreviewCard
@export var shop_card_3 : ShopPreviewCard
@export var card_prize := 5

var player_data : PlayerData
var pay_button
var original_price_text : String

func setup():
	pay_button = %PayButton
	cost_label = $PayButton/Label
	original_price_text = cost_label.text
	reset_button()
	player_data = Player.instance.data
	randomize()
	var possible_cards = all_cards_resource.all_cards
	shop_card_1.card_data = possible_cards.pick_random()
	shop_card_2.card_data = possible_cards.pick_random()
	shop_card_3.card_data = possible_cards.pick_random()


func confirm_buy():
	var cards : Array[ShopPreviewCard]
	if shop_card_1.selected:
		SfxOther._SFX_Money()
		cards.append(shop_card_1)
		await called_by.card_to_deck_animation(shop_card_1)
	if shop_card_2.selected:
		SfxOther._SFX_Money()
		cards.append(shop_card_2)
		await called_by.card_to_deck_animation(shop_card_2)
	if shop_card_3.selected:
		SfxOther._SFX_Money()
		cards.append(shop_card_3)
		await called_by.card_to_deck_animation(shop_card_3)
	
	super.send_result(cards)
	process_buy(cards)


func process_buy(cards : Array[ShopPreviewCard]):
	var cost := cards.size() * card_prize
	if cost > player_data.currency:
		return
	player_data.currency -= cost
	for card in cards:
		player_data.cardStack.append(card.card_data)
		card.visible = false
		card.selected = false
		card.is_selectable = false
	pay_button.disabled = true
	reset_button()


func _on_shop_card_clicked():
	await get_tree().process_frame
	var cost := 0
	pay_button.disabled = true
	if shop_card_1.selected:
		pay_button.disabled = false
		cost += 1
	if shop_card_2.selected:
		pay_button.disabled = false
		cost += 1
	if shop_card_3.selected:
		pay_button.disabled = false
		cost += 1
	cost *= card_prize
	set_label_gold(cost)
	if cost > player_data.currency:
		pay_button.disabled = true


func set_label_gold(amount : int):
	cost_label.text = original_price_text
	cost_label.text = cost_label.text.replace("[amount]", str(amount))


func reset_button():
	set_label_gold(0)
	pay_button.disabled = true


func _on_pay_button_button_up():
	confirm_buy()
