class_name TutorialPopupTooltip
extends TutorialPopup

var card : Card

#region override functions

func init(data : TutorialPopupData, combat : CardBattle):
	var tooltip_data = data as TutorialTooltipData
	card = combat.get_node(tooltip_data.slot_with_card).get_child(0)
	if card == null:
		push_error("ERROR! NO CARD ON SLOT!")
	card.mouse_entered.connect(on_card_mouse_entered)
	highlighted_elements.append(card)
	super.init(data, combat)


func execute():
	super.execute()

#endregion

func on_card_mouse_entered():
	highlight_elements(false)
	completed.emit()
