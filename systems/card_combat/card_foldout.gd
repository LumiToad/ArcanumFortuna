@tool
class_name Hand extends Control

@export var lerp_factor := 0.3
@export var card_spacing := 0.0
@export var card_height = 0
@export var card_hidden_height = 250
@export var card_arc = 0.05
@export var enabled := true : 
	get:
		return enabled
	set(value):
		enabled = value
		for child in get_children():
			child.set_process_input(value)

@export var show_rect : Rect2
@export var hide_rect : Rect2

@export_category("DEBUG")
@export var is_debug := false
@export var render_rects := false
@export var card : PackedScene

var __show_rect
var __hide_rect

var __show_cards = false
var is_card_dragged = false

var show_cards : bool :
	get:
		return __show_cards
	set(new_value):
		if __show_cards != new_value:
			if new_value:
				SfxOther._SFX_HandOpen()
			else:
				SfxOther._SFX_HandClose()
		__show_cards = new_value


func _ready():
	__show_rect = show_rect
	__hide_rect = hide_rect
	__show_rect.position *= get_rect().size
	__show_rect.size *= get_rect().size
	__hide_rect.position *= get_rect().size
	__hide_rect.size *= get_rect().size


func _process(delta):
	adjust_positions()
	
	if OS.has_feature("editor"):
		if render_rects or Engine.is_editor_hint():
			queue_redraw()
		if Engine.is_editor_hint():
			return
	
	var count = get_child_count()
	
	if enabled and not is_card_dragged and count > 0:
		if __show_rect.has_point(get_local_mouse_position()):
			show_cards = true
		if not __hide_rect.has_point(get_local_mouse_position()):
			show_cards = false
	
	if !enabled or is_card_dragged:
		show_cards = false
	
	if card && is_debug:
		if Input.is_action_just_pressed("ui_up"):
			var c = card.instantiate()
			add_child(c)
	
		if Input.is_action_just_pressed("ui_down"):
			if count == 0:
				return
		
			get_child(count - 1).queue_free()


func adjust_positions():
	var count = get_child_count()
	
	if count < 1:
		return
	
	var idx = 0
	for child in get_children():
		var card = child as Card
		if not card:
			continue
		if "isPickedUp" in card and card.isPickedUp:
			continue
		
		var width = card.get_rect().size.x + card_spacing
		var posX = get_rect().size.x / 2.0
		if count > 1:
			posX += (idx - count / 2.0) * (min(width * count, get_rect().size.x) / count)
		var posY = -curve(posX - get_rect().size.x / 2.0)
		card.position = card.position.lerp(Vector2(posX, -posY), lerp_factor)
		var rot = -derivative(posX - get_rect().size.x / 2.0)
		card.rotation = lerpf(card.rotation, rot, lerp_factor)
		idx += 1
	
	if lerp_factor >= 1:
		lerp_factor = 0.1


func _draw():
	__show_rect = show_rect
	__hide_rect = hide_rect
	__show_rect.position *= get_rect().size
	__show_rect.size *= get_rect().size
	__hide_rect.position *= get_rect().size
	__hide_rect.size *= get_rect().size
	
	if OS.has_feature("editor") and Engine.is_editor_hint():
		draw_rect(__show_rect, Color.hex(0x00ff0002))
		draw_rect(__hide_rect, Color.hex(0xff000002))


func _on_card_drag_started():
	is_card_dragged = true

func _on_card_drag_ended(card):
	if not card in get_children():
		card.reparent(self)
	is_card_dragged = false

func _on_card_added(card : HandCard):
	if card.drag_started.is_connected(_on_card_drag_started):
		return
	card.drag_started.connect(_on_card_drag_started)
	card.drag_ended.connect(_on_card_drag_ended)


func curve(x):
	return (x * x) * (card_arc * 0.001) + (card_height if show_cards else card_hidden_height)


func derivative(x):
	return -2 * x * (card_arc * 0.001)
