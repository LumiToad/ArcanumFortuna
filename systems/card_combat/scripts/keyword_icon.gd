extends TextureRect

@export var grid_rows := 2
@export var grid_columns := 3

@export var descriptions : Array[KeywordDescription]
@export var generate_tooltip := false

signal animation_finished

var origin_position
var __is_animating := false
var is_animating: bool:
	set(new_value):
		__is_animating = new_value
		animation_finished.emit()
	get:
		return __is_animating


func _ready():
	origin_position = position


func set_icon(keyword : Keyword):
	if keyword == null:
		visible = false
		return
	texture = keyword.icon
	visible = true
	
	if not generate_tooltip:
		return
		
	var tooltip = ShowTooltip.new()
	tooltip.hover_min_duration = 0.8
	tooltip.title = keyword.title
	tooltip.icon = keyword.icon
	tooltip.text = keyword.description
	add_child(tooltip)
