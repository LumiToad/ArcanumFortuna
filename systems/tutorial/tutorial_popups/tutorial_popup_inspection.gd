class_name TutorialPopupInspection
extends TutorialPopup

var card_inspection

func _input(event):
	if Input.is_action_just_released("open_inspection"):
		await get_tree().process_frame
		for node in SceneHandler.ui_container.get_children():
			if node is CardInspection:
				node.inspection_closed.connect(on_inspection_closed)


#region override functions


func init(data : TutorialPopupData, combat : CardBattle):
	super.init(data, combat)


func execute():
	super.execute()


#endregion


func on_inspection_closed():
	highlight_elements(false)
	completed.emit()
	
