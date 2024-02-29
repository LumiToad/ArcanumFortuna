class_name CardData extends Resource

@export var name := "Your Card"
@export_multiline var description := "It can do stuff."
@export var artwork: Texture2D
## The Karma value of the card, can be both negative and positive.
@export var cost := 1
## The Attack value of the card. Must be positive.
@export var attack := 1
## The Health value of the card. Must be positive.
@export var health := 1
@export var keywords : Array[Keyword]
@export var spawn_frequency : int = 100
## The cost of a card to use within a shop.
@export var shop_cost := 5
## If a value greater than zero is used the cards trade discount will be overriden with this value.
@export var trade_override := 0
@export var sound_effect: AudioStream
@export var keyword_slot_texture : Texture = preload("res://assets/ui/icons/keyword_slots.png")
var owner : Card
