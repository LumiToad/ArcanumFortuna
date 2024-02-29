class_name ShopEvent
extends EventBase

var seed := 0
var player_data_ref: PlayerData


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	var shop = SceneHandler.add_ui_element("res://systems/ui/menus/shop/shop.tscn") as Shop
	shop.init(10, self)
	shop.set_seed(seed)
	shop.setup()
	SfxBg._playTrack(SfxBg.MapTypes.SHOP)
	shop.shop_closed.connect(emit_finished)


func emit_finished():
	finished.emit()
