class_name ShopKeeper
extends EventBase

signal close_shop

@export var card_template: PackedScene
@export var select_prompt: PackedScene
## Which cards can the trader sell?
@export var cards_to_offer: Array[CardData]
## How much discount is this trader offering? Can only be between 0 and 1
@export_range(0.0, 1.0) var discount := 0.3

@export_category("Debug")
## Debug Player Data to use
@export var debug_player_data: PlayerData
## Only for debugging
@export var is_debug := false

var player_data_ref: PlayerData
var rng := RandomNumberGenerator.new()
var seed := 0
var processing_purchase := false

func _ready():
	if get_tree().current_scene == self:
		setup(debug_player_data)


func setup(player_data: PlayerData):
	player_data_ref = player_data
	rng.seed = seed
	populate_shop()


func _process(delta):
	if not player_data_ref:
		return
	
	%Money.text = str(player_data_ref.currency)


func populate_shop():
	var grabbag = cards_to_offer.duplicate()
	for slot in %BuyCards/Cards.get_children():
		var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
		var instance = card_template.instantiate() as ShopCard
		instance.load_from_data(c)
		instance.can_afford_card(player_data_ref.currency)
		instance.setup()
		instance.clicked.connect(card_clicked)
		slot.add_child(instance)
	
	for slot in %TradeCards/Cards.get_children():
		var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
		var instance = card_template.instantiate() as ShopCard
		instance.load_from_data(c)
		instance.is_trade_card = true
		instance.can_afford_card(player_data_ref.currency)
		instance.clicked.connect(card_clicked)
		instance.setup()
		slot.add_child(instance)
	
	%HealthCards.setup(rng, player_data_ref)


func card_clicked(card: ShopCard):
	if processing_purchase:
		return
	processing_purchase = true
	if not card.affordable:
		return
	
	player_data_ref.currency -= card.get_costs()
	var data = card.card_data
	card.queue_free()
	
	# recalculate wealth after purchase
	for slot in %TradeCards/Cards.get_children():
		if slot.get_child_count() <= 0:
			continue
		slot.get_child(0).can_afford_card(player_data_ref.currency)
	
	for slot in %BuyCards/Cards.get_children():
		if slot.get_child_count() <= 0:
			continue
		slot.get_child(0).can_afford_card(player_data_ref.currency)
	
	if card.is_trade_card:
		var prompt = select_prompt.instantiate() as CardPick
		add_child(prompt)
		var grabbag = player_data_ref.cardStack.duplicate()
		var options: Array[CardData] = []
		for i in range(3):
			var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
			options.append(c)
		
		var result = await prompt.prompt_for_card(options)
		for i in range(len(player_data_ref.cardStack)):
			if player_data_ref.cardStack[i].name == result.name:
				player_data_ref.cardStack.remove_at(i)
				break

	player_data_ref.cardStack.append(data)
	processing_purchase = false


func _on_close_shop_pressed():
	close_shop.emit()
	queue_free()
