class_name TutorialPopupEnd
extends TutorialPopup

@onready var end_button := %EndButton

#region override functions


func init(data : TutorialPopupData, combat : CardBattle):
	super.init(data, combat)
	if data is TutorialEndData:
		end_button.text = data.button_name


func execute():
	super.execute()


#endregion

func _on_end_button_button_up():
	highlight_elements(false)
	SceneHandler.change_scene("res://systems/ui/menus/main_menu/main_menu.tscn")
	completed.emit()
