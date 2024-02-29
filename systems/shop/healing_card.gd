class_name HealingCard
extends Control

signal clicked(HealingCard)

@export var healing_amount = 3
@export var costs = 6

var hovered := false
var affordable := false

func set_value(amount: int, price: int):
	healing_amount = amount
	costs = price
	%HealingAmount.text = str(amount)
	%Cost.text = str(price)


func can_afford(current_amount: int):
	affordable = current_amount >= costs


func _process(delta):
	%selected.visible = hovered and affordable
	
	hovered = Rect2(Vector2.ZERO, get_rect().size).has_point(get_local_mouse_position())


func _gui_input(event: InputEvent):
	if event.is_action("pickUpCard"):
		clicked.emit(self)
