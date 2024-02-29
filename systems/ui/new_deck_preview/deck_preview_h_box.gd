class_name DeckPreviewHBox
extends TextureRect


func try_add_card(deck_card_instance):
	if get_child(0).get_child_count() > 4:
		return false
	
	get_child(0).add_child(deck_card_instance)
	
	return true
