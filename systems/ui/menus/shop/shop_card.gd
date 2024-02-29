class_name ShopPreviewCard
extends SelectCard


func _input(event):
	if is_hovered and event.is_action_pressed("open_inspection"):
		var new_inspection = inspection.instantiate() as CardInspection
		new_inspection.init(75, self)
		new_inspection.inspection_init(self)
		SceneHandler.add_ui_element(new_inspection)
	
	if is_hovered and event.is_action_pressed("pickUpCard"):
		clicked.emit()
		self.selected = not selected
		self.selected_shader.visible = selected
