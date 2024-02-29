class_name UITabBase
extends Control

var is_current_tab := false
var called_by


func init(caller):
	called_by = caller
	is_current_tab = true


func setup():
	pass


func close():
	is_current_tab = false
	queue_free()


func _input(event):
	if is_current_tab == false:
		return


func call_ui_element_by_caller(element):
	if called_by is UIBase:
		called_by.call_ui_element(element)


func call_ui_popup_by_caller(popup_data : UIPopupData):
	if called_by is UIBase:
		called_by.call_ui_popup(popup_data)


func send_result(result):
	if called_by.has_method("receive_result"):
		called_by.receive_result(result)
