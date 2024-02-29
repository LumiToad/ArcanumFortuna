class_name UIPopupData
extends Resource

var ui_popup_path := "res://systems/ui/ui_base/ui_popup.tscn"
var ui_popup_line_edit_path := "res://systems/ui/ui_base/ui_popup_line_edit.tscn"

@export var title_text : String
@export_multiline var content_text : String
@export var confirm_label_text : String
@export var decline_label_text : String
