class_name Shop
extends UIBase

signal shop_closed

@export var close_unfinished_popup : UIPopupData
@export var shop_buy_tab : PackedScene
@export var shop_trade_tab : PackedScene
@export var shop_burn_tab : PackedScene

var buy_tab_instance
var trade_tab_instance
var burn_tab_instance
var last_clicked_tab
var player_data : PlayerData
var seed := 1337
var rng = RandomNumberGenerator.new()

func _process(delta):
	if is_current_window:
		last_clicked_tab.grab_focus()


func setup():
	SfxBg._playTrack(SfxBg.MapTypes.SHOP)
	last_clicked_tab = %BuySectionButton
	player_data = Player.instance.data
	buy_tab_instance = instance_tab(shop_buy_tab)
	buy_tab_instance.visible = false
	trade_tab_instance = instance_tab(shop_trade_tab)
	trade_tab_instance.visible = false
	burn_tab_instance = instance_tab(shop_burn_tab)
	burn_tab_instance.visible = false
	current_tab = buy_tab_instance
	switch_tab_visible(buy_tab_instance)


func set_seed(seed : int):
	self.seed = seed
	rng.seed = seed


func instance_tab(tab : PackedScene):
	var tab_instance = tab.instantiate() as UITabBase
	tab_instance.init(self)
	tab_instance.setup()
	add_child(tab_instance)
	
	return tab_instance


func receive_result(result):
	if result is bool and result == true:
		self.close()


func card_to_deck_animation(card):
	var tree = SceneHandler.current_scene.get_tree()
	var deck
	for node in SceneHandler.ui_container.get_children():
		if node is DeckInMenu:
			deck = node.get_child(0).get_child(0)
	
	var tween : Tween = tree.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	card.selected_shader.visible = false
	card.play_cardflip(false)
	tween.tween_property(card, "global_position", deck.global_position, 0.5)
	await tween.finished


func get_all_nodes(node):
	var array : Array
	
	if node.get_child_count() > 0:
		for found_node in node.get_children():
			array.append_array(get_all_nodes(found_node))
			array.append(found_node)
		return array
	return array


func has_unfinished_trades():
	var count := 0
	for node in get_all_nodes(self):
		if node.has_method("is_selected"):
			count += 1
		if node is SelectCard and node.selected:
			count += 1
		if node is ShopBurnSection and node.burn_card.visible:
			count += 1
	
	return count > 0


func close():
	shop_closed.emit()
	super.close()

func _on_buy_section_button_button_up():
	last_clicked_tab = %BuySectionButton
	super.switch_tab_visible(buy_tab_instance)


func _on_trade_section_button_button_up():
	last_clicked_tab = %TradeSectionButton
	super.switch_tab_visible(trade_tab_instance)


func _on_burn_section_button_button_up():
	last_clicked_tab = %BurnSectionButton
	super.switch_tab_visible(burn_tab_instance)


func _on_leave_shop_button_button_up():
	if has_unfinished_trades():
		var popup = SceneHandler.add_ui_element(close_unfinished_popup.ui_popup_path) as UIPopup
		popup.init(get_layer(), self)
		popup.setup_popup(close_unfinished_popup)
	else:
		self.close()
