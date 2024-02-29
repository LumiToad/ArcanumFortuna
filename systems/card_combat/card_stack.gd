class_name CardStack extends Control

## Node that should hold the cards for drawing
@export var target: Node
@export var deckCardTemplate: PackedScene
@export var rng_seed := 1337

@export var fill_textures : Array[Texture]

var rng : RandomNumberGenerator

var cardStack := []

func _ready() -> void:
	update_text()
	if cardStack.size() != 0 and cardStack.size() <= fill_textures.size():
		%DeckTexture.texture = fill_textures[cardStack.size() - 1]
	
func init(seed : int):
	rng_seed = seed
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed


func update_text():
	%CardCount.text = str(cardStack.size())


func shuffle():
	if rng == null:
		cardStack.shuffle()
		return
	
	for i in range(len(cardStack) - 1, 0, -1):
		var other = rng.randi_range(0, len(cardStack) - 1)
		if i == other:
			continue
		var t = cardStack[i]
		cardStack[i] = cardStack[other]
		cardStack[other] = t


func put_card_in_stack(card: CardData):
	cardStack.append(card)
	update_text()


func draw_card(hand: Node):
	if len(cardStack) <= 0:
		return null
	
	var cardData = cardStack.pop_back()
	var card = deckCardTemplate.instantiate() as Card
	card.load_from_data(cardData)
	add_child(card)
	card.visible = false
	card.global_position = get_child(0).global_position
	await get_tree().process_frame
	if cardStack.size() == 0:
		hide()
	elif cardStack.size() <= fill_textures.size():
		%DeckTexture.texture = fill_textures[cardStack.size() - 1]
	card.visible = true
	var tween = create_tween()
	card.play_cardflip(true)
	var hand_center =  hand.get_global_rect().get_center()
	tween.set_trans(tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card, "global_position", hand_center, 0.5).from_current()
	await tween.finished
	card.reparent(hand)

	#visible = len(cardStack) > 0
	update_text()
	return card
