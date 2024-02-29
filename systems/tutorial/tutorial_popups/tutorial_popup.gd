class_name TutorialPopup
extends Control

signal completed

var arrow_template_path := "res://systems/tutorial/arrow_template.tscn"
var highlighted_elements : Array[Node]
var clickable_rects : Array[Rect2]
var data : TutorialPopupData
var combat : CardBattle

@onready var container := %MarginContainer
@onready var title := %Title
@onready var text := %Text
@onready var background := %Background

func _process(delta):
	background.global_position = Vector2.ZERO


#region override functions


func init(data : TutorialPopupData, combat : CardBattle):
	visible = false
	self.data = data
	self.combat = combat
	title.text = data.title
	text.text = data.text


func execute():
	for node_path in data.highlighted_elements:
		highlighted_elements.append(combat.get_node(node_path))
	for node in highlighted_elements:
		clickable_rects.append((node as Control).get_global_rect())
	var position = get_viewport_rect().get_center()
	if highlighted_elements.size() > 0:
		position = highlighted_elements[0].get_global_rect().get_center()
	setup_window_position(position)
	if data.arrows.size() > 0:
		setup_arrow_positions()
	highlight_elements(true)
	await get_tree().process_frame
	visible = true


#endregion


func highlight_elements(value : bool):
	for node in highlighted_elements:
		node.set_z_index(100 if value else 0)



func get_offset_type_rotation(offset_type : TutorialPopupData.OffsetType):
	var rotation
	
	match offset_type:
		TutorialPopupData.OffsetType.UP:
			rotation = 90
		TutorialPopupData.OffsetType.DOWN:
			rotation = 270
		TutorialPopupData.OffsetType.LEFT:
			rotation = 0
		TutorialPopupData.OffsetType.RIGHT:
			rotation = 180
		TutorialPopupData.OffsetType.UP_LEFT:
			rotation = 45
		TutorialPopupData.OffsetType.UP_RIGHT:
			rotation = 135
		TutorialPopupData.OffsetType.DOWN_LEFT:
			rotation = 315
		TutorialPopupData.OffsetType.DOWN_RIGHT:
			rotation = 225
	
	return rotation


func get_offset_type_position(offset_type : TutorialPopupData.OffsetType, distance : float):
	var offset = Vector2.ZERO
	
	match offset_type:
		TutorialPopupData.OffsetType.UP:
			offset.y = -distance
		TutorialPopupData.OffsetType.DOWN:
			offset.y = distance
		TutorialPopupData.OffsetType.LEFT:
			offset.x = -distance
		TutorialPopupData.OffsetType.RIGHT:
			offset.x = distance
		TutorialPopupData.OffsetType.UP_LEFT:
			offset.x = -distance
			offset.y = -distance
		TutorialPopupData.OffsetType.UP_RIGHT:
			offset.x = distance
			offset.y = -distance
		TutorialPopupData.OffsetType.DOWN_LEFT:
			offset.x = -distance
			offset.y = distance
		TutorialPopupData.OffsetType.DOWN_RIGHT:
			offset.x = distance
			offset.y = distance
	
	return offset


func setup_window_position(center_position : Vector2):
	global_position = center_position
	var center = container.get_rect().get_center()
	position.x -= center.x
	position.y -= center.y
	var offset = get_offset_type_position(data.offset_type, data.distance)
	position += offset


func setup_arrow_positions():
	var arrow_template = load(arrow_template_path)
	for arrow_data in data.arrows:
		var arrow = arrow_template.instantiate()
		var element = combat.get_node(arrow_data.element)
		add_child(arrow)
		var element_center = element.get_global_rect().get_center()
		arrow.global_position = element_center
		arrow.global_position += get_offset_type_position(arrow_data.offset_type , arrow_data.distance * 2)
		arrow.pivot_offset.x += arrow_data.distance
		arrow.rotation_degrees = get_offset_type_rotation(arrow_data.offset_type)
		var direction = arrow.global_position.direction_to(element_center)
		tween_arrow(arrow, direction)

func tween_arrow(arrow, direction):
	var tween = self.create_tween()
	var end_pos = arrow.position + direction * 15
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(arrow, "position", end_pos, 0.5).from_current()
	tween.tween_interval(0.1)
	tween.tween_callback(tween_arrow.bind(arrow, direction * -1))
