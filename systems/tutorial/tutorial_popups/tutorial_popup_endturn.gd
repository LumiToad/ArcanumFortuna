class_name TutorialPopupEndturn
extends TutorialPopup

#region override functions

func init(data : TutorialPopupData, combat : CardBattle):
	super.init(data, combat)


func execute():
	super.execute()
	combat.unlock_player_actions()
	combat.player_turn_ended.connect(on_player_turn_ended)


#endregion


func on_player_turn_ended():
	highlight_elements(false)
	combat.lock_player_actions()
	completed.emit()
