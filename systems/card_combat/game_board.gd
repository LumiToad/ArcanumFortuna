class_name GameBoard
extends VBoxContainer

@export var combat_card_prefab : PackedScene

@export var enemy_player : EnemyPlayer
@export var player : CardPlayer

@export_category("Style")
@export var tile_disabled_color : Color
@export var tile_interactible_color : Color
@export var tile_hovered_color : Color

var accept_card := false
var hovered_tile = null

@onready var player_tiles = $PlayerTiles
@onready var enemy_tiles_back = $EnemyTiles/Backrow
@onready var enemy_tiles_front = $EnemyTiles/Frontrow

const width = 5

func _ready():
	for tile in $EnemyTiles.get_child(0).get_children():
		tile.self_modulate = tile_disabled_color
	for tile in $EnemyTiles.get_child(1).get_children():
		tile.self_modulate = tile_disabled_color
	for tile in player_tiles.get_children():
		tile.self_modulate = tile_disabled_color
		tile.mouse_entered.connect(
			func (): 
				if not accept_card:
					return
				tile.self_modulate = tile_hovered_color
				hovered_tile = tile
		)
		tile.mouse_exited.connect(
			func (): 
				tile.self_modulate = tile_interactible_color if accept_card else tile_disabled_color
				if hovered_tile == tile: 
					hovered_tile = null
		)


func get_friendly_tile_position(x):
	return player_tiles.get_child(x).global_position


func get_enemy_tile_pos(y, x):
	return $EnemyTiles.get_child(y).get_child(x).global_position


func is_front_tile_empty(tile_idx : int, is_friendly : bool):
	return player_tiles.get_child(tile_idx).get_child_count() == 0 if is_friendly else \
			enemy_tiles_front.get_child(tile_idx).get_child_count() == 0


func is_back_tile_empty(tile_idx : int):
	return enemy_tiles_back.get_child(tile_idx).get_child_count() == 0


func _on_card_dragged():
	for tile in player_tiles.get_children():
		if tile.get_child_count() > 0:
			continue
		tile.self_modulate = tile_interactible_color
	accept_card = true


func _on_card_relased(card: Card):
	for tile in player_tiles.get_children():
		tile.self_modulate = tile_disabled_color
	accept_card = false
	if not hovered_tile or hovered_tile.get_child_count() != 0:
		return
	card.get_node("SFXCard")._SFX_PutDown()
	card.reparent(hovered_tile)
	card.global_position = hovered_tile.global_position + Vector2(-20, -40)
	card.z_index = 2


func lock_friendly_cards(combat):
	var i := -1
	for tile in player_tiles.get_children():
		i += 1
		if tile.get_child_count() == 0:
			continue
		var card = tile.get_child(0)
		if card is CombatCard:
			continue
		var new_combat_card = combat_card_prefab.instantiate()
		new_combat_card.copy(card)
		tile.add_child(new_combat_card)
		new_combat_card.tile_coordinate = Vector2i(i, 0)
		new_combat_card.deleted.connect(player._on_friendly_card_deleted)
		combat.player.transfer_stored_buffs(new_combat_card)
		GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
		[new_combat_card.card_data.name, i, 0])
		card.reparent(SceneHandler.shelf)
		card.queue_free()
		await get_tree().process_frame
		await combat._on_card_played(new_combat_card)
		await get_tree().process_frame


func place_friendly_card(cardData : CardData, tile_idx) -> bool:
	var target_tile = player_tiles.get_child(tile_idx)
	if target_tile.get_child_count() != 0:
		push_error("Can't place card. Player slot of id ", tile_idx, " is already filled!")
		return false
	var new_combat_card = combat_card_prefab.instantiate()
	new_combat_card.card_data = cardData
	target_tile.add_child(new_combat_card)
	new_combat_card.make_enemy()
	new_combat_card.tile_coordinate = Vector2i(tile_idx, 1)
	GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
	[new_combat_card.card_data.name, tile_idx, 1])
	await get_tree().process_frame
	return true


func place_enemy_card_front(cardData : CardData, tile_idx) -> bool:
	var target_tile = enemy_tiles_front.get_child(tile_idx)
	if target_tile.get_child_count() != 0:
		push_error("Can't place card. Enemy slot of id ", tile_idx, " is already filled!")
		return false
	var new_combat_card = combat_card_prefab.instantiate()
	new_combat_card.card_data = cardData
	target_tile.add_child(new_combat_card)
	new_combat_card.make_enemy()
	new_combat_card.tile_coordinate = Vector2i(tile_idx, 1)
	GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
	[new_combat_card.card_data.name, tile_idx, 1])
	await get_tree().process_frame
	return true


func try_move_card_sideways(current_tile_idx: int, target_tile_idx: int, is_friendly: bool):
	var tiles = player_tiles if is_friendly else enemy_tiles_front
	
	if tiles.get_child(target_tile_idx).get_child_count() != 0:
		return false
	if tiles.get_child(current_tile_idx).get_child_count() == 0:
		push_error("Tried to move card from empty tile.")
		return false
	await tiles.get_child(current_tile_idx).get_child(0).animate_move(
		get_friendly_tile_position(target_tile_idx) if is_friendly else get_enemy_tile_pos(1, target_tile_idx))
	tiles.get_child(current_tile_idx).get_child(0).tile_coordinate.x = target_tile_idx
	tiles.get_child(current_tile_idx).get_child(0).reparent(tiles.get_child(target_tile_idx))
	return true

func try_move_enemy_card_to_front(tile_idx):
	if enemy_tiles_front.get_child(tile_idx).get_child_count() != 0:
		return false
	if enemy_tiles_back.get_child(tile_idx).get_child_count() == 0:
		push_error("Tried moving nonexistent enemy at back tile ", tile_idx)
		return false
	await enemy_tiles_back.get_child(tile_idx).get_child(0).animate_move(get_enemy_tile_pos(1, tile_idx))
	enemy_tiles_back.get_child(tile_idx).get_child(0).reparent(enemy_tiles_front.get_child(tile_idx))
	enemy_tiles_front.get_child(tile_idx).get_child(0).tile_coordinate.y = 1
	await get_tree().process_frame
	return true
	
	
func place_enemy_card_back(cardData : CardData, tile_idx) -> bool:
	var target_tile = enemy_tiles_back.get_child(tile_idx)
	if target_tile.get_child_count() != 0:
		push_error("Can't place card. Enemy slot of id ", tile_idx, " is already filled!")
		return false
	var new_combat_card = combat_card_prefab.instantiate()
	new_combat_card.card_data = cardData
	target_tile.add_child(new_combat_card)
	new_combat_card.make_enemy()
	new_combat_card.tile_coordinate = Vector2i(tile_idx, 2)
	GlobalLog.add_entry("Card '%s' was placed on board at position %d-%d." % \
	[new_combat_card.card_data.name, tile_idx, 2])
	return true


func get_target(tile_idx, is_friendly = false):
	if is_friendly:
		if tile_idx < 0 || tile_idx >= enemy_tiles_front.get_child_count():
			return null
		return enemy_tiles_front.get_child(tile_idx).get_child(0) \
			if enemy_tiles_front.get_child(tile_idx).get_child_count() != 0 else enemy_player
	if tile_idx < 0 || tile_idx >= player_tiles.get_child_count():
		return null
	return player_tiles.get_child(tile_idx).get_child(0) \
		if player_tiles.get_child(tile_idx).get_child_count() != 0 else player


func get_friendly_cards() -> Array[CombatCard]:
	var res : Array[CombatCard]
	for tile in player_tiles.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_front_enemies() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_front.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_back_enemies() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_back.get_children():
		if tile.get_child_count() != 0 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
	return res


func get_enemy_front_row() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_front.get_children():
		if tile.get_child_count() >= 1 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
		else:
			res.push_back(null)
	return res


func get_enemy_back_row() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in enemy_tiles_back.get_children():
		if tile.get_child_count() != 0 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
		else:
			res.push_back(null)
	return res


func get_friendly_row() -> Array[CombatCard]:
	var res : Array[CombatCard] = []
	for tile in player_tiles.get_children():
		if tile.get_child_count() != 0 && tile.get_child(0) is CombatCard:
			res.push_back(tile.get_child(0))
		else:
			res.push_back(null)
	return res


func get_active_cards() -> Array[CombatCard]:
	return get_friendly_cards() + get_front_enemies()


func get_tile(idx, friendly = false):
	return (player_tiles if not friendly else $EnemyTiles/Frontrow).get_child(idx)


func highlight_tile(idx, friendly = false):
	get_tile(idx, friendly).self_modulate = tile_hovered_color


func end_tile_highlight(idx, friendly = false):
	get_tile(idx, friendly).self_modulate = tile_disabled_color


func _on_card_deletion_button_toggled(toggled_on):
	for card : CombatCard in get_friendly_cards():
		card.set_delete_mode(toggled_on)
