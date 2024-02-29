class_name UIPopup
extends UIBase

@onready var title : RichTextLabel = %Title
@onready var content : RichTextLabel = %Content
@onready var confirm_button : TextureButton = %ConfirmButton
@onready var decline_button : TextureButton = %DeclineButton


func setup_popup(data : UIPopupData):
	self.title.text = data.title_text
	self.content.text = data.content_text
	self.confirm_button.get_child(0).text = data.confirm_label_text
	self.decline_button.get_child(0).text = data.decline_label_text


func _on_confirm_button_up():
	close_with_result(true)


func _on_decline_button_up():
	close_with_result(false)


func close_with_result(value):
	super.close_with_result(value)

