class_name NodeMap
extends Control

var rng: RandomNumberGenerator
var level := 0.0


func _ready():
	SfxBg._playTrack(SfxBg.MapTypes.WINTER)
	ScreenFade.fade_in(1.0)


func _process(delta):
	if OS.has_feature("no-cheat"):
		return
	if Input.is_action_just_pressed("debug_quit"):
		var shop = SceneHandler.add_ui_element("res://systems/ui/menus/shop/shop.tscn") as Shop
		shop.init(10, self)
		shop.setup()
		SfxBg._playTrack(SfxBg.MapTypes.SHOP)
		await shop.shop_closed


func init(rng_seed, rng_text):
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	$CanvasLayer/SeedLabel.set_seed(rng_text)
	setup_ui()


func setup_ui():
	var deck_in_menu = SceneHandler.add_ui_element("res://systems/ui/menus/deck_in_menu.tscn") as DeckInMenu
	deck_in_menu.init(75, self)
	deck_in_menu.setup()
	var player_resources = SceneHandler.add_ui_element("res://systems/ui/menus/utils/player_resource_ui.tscn")
	player_resources.init(70, self)
	player_resources.setup()


func _on_node_activated(node : EventNode):
	$CanvasLayer/SeedLabel.hide()
	node.init(level, rng)


func _on_node_completed(node : EventNode):
	SfxBg._playTrack(SfxBg.MapTypes.WINTER)
	level += node.level_gain
	$CanvasLayer/SeedLabel.show()
