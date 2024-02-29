extends TutorialAction

@export var card_battle: CardBattle
@export var card_to_play: CardData
@export_range(1, 5) var card_slot := 3

func _execute():
	card_battle.game_board.place_enemy_card_back(card_to_play, card_slot - 1)
