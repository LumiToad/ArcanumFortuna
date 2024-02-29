class_name TutorialPopupPlaycard
extends TutorialPopup

var target_card_slot : Control
var hand
var player_tiles

var card


#region override functions


func init(data : TutorialPopupData, combat : CardBattle):
	var playcard_data = data as TutorialPlaycardData
	hand = combat.player.hand
	player_tiles = combat.game_board.player_tiles.get_children()
	target_card_slot = combat.get_node(playcard_data.target_card_slot)
	highlighted_elements.append(hand)
	highlighted_elements.append(target_card_slot)
	super.init(data, combat)
	combat.game_board.player.card_drag_ended.connect(on_card_drag_ended)


func execute():
	super.execute()
	self.highlight_elements(true)
	combat.unlock_player_actions()


func highlight_elements(value : bool):
	for node in highlighted_elements:
		node.set_z_index(100 if value else 0)
	
	var color = Color.WHITE
	color.a = 0
	if value:
		color = Color.WHITE_SMOKE
		color.a = 0.15
	target_card_slot.set_self_modulate(color)
	
	for tile : Node in player_tiles:
		if value:
			if tile != target_card_slot:
				pass # Should disable tile here
		else:
				pass # Should enable all


#endregion


func on_card_drag_ended(card):
	complete_condition(card)


func complete_condition(card):
	if target_card_slot.get_child(0) == card:
		self.card = card
		highlight_elements(false)
		completed.emit()
