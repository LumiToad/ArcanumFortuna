extends Control

@export var more_icon : Texture2D
@export var less_icon : Texture2D


func _ready():
	await get_tree().process_frame
	GlobalLog.entry_added.connect(_on_entry_text_added)
	%ExpandButton.icon = more_icon


func _on_entry_text_added(entry_text):
	%Log.text = %Log.text + entry_text + "\n"


func _on_expand_button_toggled(toggled_on):
	%ScrollView.visible = toggled_on
	%ExpandButton.icon = less_icon if toggled_on else more_icon
