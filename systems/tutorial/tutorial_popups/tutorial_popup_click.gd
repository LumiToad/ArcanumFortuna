class_name TutorialPopupClick
extends TutorialPopup

@onready var next_button := %NextButton

#region override functions


func init(data : TutorialPopupData, combat : CardBattle):
	super.init(data, combat)


func execute():
	super.execute()

#endregion

func _on_next_button_button_up():
	highlight_elements(false)
	completed.emit()
