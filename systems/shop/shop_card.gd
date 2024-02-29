class_name ShopCard
extends Card

signal clicked(card: ShopCard)

@export var discount := 0.3

var is_trade_card := false
var hovered := false
var affordable := false

func setup():
	super.setup()
	if card_data:
		%Costs.text = str(get_costs())


func can_afford_card(available_money: int) -> bool:
	affordable = available_money >= get_costs()
	
	return affordable


func get_costs():
	if is_trade_card:
		if card_data.trade_override > 0:
			return card_data.trade_override
		return max(floor(card_data.shop_cost - max(1, ceili(float(card_data.shop_cost) * discount))), 1)
	
	return card_data.shop_cost


func _process(delta):
	%selected.visible = hovered and affordable
	
	hovered = Rect2(Vector2.ZERO, get_rect().size).has_point(get_local_mouse_position())


func _gui_input(event):
	if is_hovered and event.is_action_pressed("open_inspection"):
		var new_inspection = inspection.instantiate()
		new_inspection.init(self)
		get_parent().get_parent().get_parent().get_parent().get_parent().add_child(new_inspection)
	
	if event.is_action("pickUpCard"):
		clicked.emit(self)
