class_name ShopBurnSection
extends UITabBase

@export var all_cards_resource : AllCards
@export var cost_label : Label
@export var burn_card : ShopPreviewCard
@export var deck_preview_overlay : PackedScene
@export var popup : UIPopupData
@export var card_prize := 4

var deck_preview : DeckPreviewOverlay
var player_data : PlayerData
var burn_button
var cards_to_burn : Array[CardData]
var original_price_text : String


func setup():
	burn_button = $BurnButton
	cost_label = $BurnButton/Label
	original_price_text = cost_label.text
	burn_card.visible = false
	player_data = Player.instance.data
	reset_button()


func select_card():
	if player_data.cardStack.size() < 1:
		return
	if player_data.currency < card_prize:
		burn_button.disabled = true
		return
	
	if not deck_preview:
		deck_preview = SceneHandler.add_ui_element(deck_preview_overlay) as DeckPreviewOverlay
		deck_preview.init(75, self)
		deck_preview.is_selectable = true
		deck_preview.setup()
	else:
		await deck_preview.close()
		deck_preview = null


func receive_result(result):
	if result is bool and result == false:
		return
	if result is bool and result == true:
		SfxOther._SFX_Money()
		execute_burn_card()
	if result is Array[CardData]:
		burn_card.visible = true
		cards_to_burn = result
		burn_card.load_from_data(cards_to_burn[0])
		burn_card.play_animation("RESET")
		burn_card.set_shader_value(-1.0)
		set_label_gold(cards_to_burn.size() * card_prize)
	if player_data.currency >= card_prize * cards_to_burn.size():
		burn_button.disabled = false


func execute_burn_card():
	for card in cards_to_burn:
		erase_card_from_player(card)
		player_data.currency -= card_prize
	for card in cards_to_burn:
		burn_card.load_from_data(card)
		await burn_card.animate_burn()
	
	cards_to_burn.clear()
	burn_card.visible = false
	reset_button()


func erase_card_from_player(card_data : CardData):
	for card in player_data.cardStack:
		if card.name == card_data.name and card.attack == card_data.attack:
			player_data.cardStack.erase(card)
			return


func set_label_gold(amount : int):
	cost_label.text = original_price_text
	cost_label.text = cost_label.text.replace("[amount]", str(amount))


func reset_button():
	set_label_gold(0)
	burn_button.disabled = true


func _on_burn_button_button_up():
	var popup_instance = SceneHandler.add_ui_element(popup.ui_popup_path) as UIPopup
	popup_instance.init(20, self)
	popup_instance.setup_popup(popup)


func _on_texture_button_button_up():
	select_card()
