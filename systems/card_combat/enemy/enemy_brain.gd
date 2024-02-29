class_name EnemyBrain extends Resource


@export var available_cards : Array[CardData]

@export_category("Strategy")
@export var strategy_modules : Array[EnemyBrainStrategyModule]

var rng := RandomNumberGenerator.new()
var stats : EnemyBrainStats 
var rows : Array[Array] = []
var owner : EnemyPlayer
var board : GameBoard
var combat : CardBattle


func init(stats: EnemyBrainStats, new_owner : EnemyPlayer, combat_context : CardBattle, seed : int):
	owner = new_owner
	self.stats = stats
	rng.seed = seed if seed != -1 else randi()
	combat = combat_context
	board = combat.game_board


func get_random_health():
	return rng.randi_range(stats.min_health, stats.max_health)


func calc_card_placements() -> Array[CardPlacement]:
	var target_columns = get_randomised_target_colums()
	
	if target_columns.size() == 0:
		return []
	var possible_moves = get_possible_moves(target_columns)

	for module : EnemyBrainStrategyModule in strategy_modules:
		module.add_points_to_possible_moves(possible_moves, combat)
	
	var max_points = possible_moves.reduce( \
			func(max, move): \
	 			return move.points if move.points > max else max \
			, 0.0)
	print("[Enemy Brain] Best possible Move Point value: ", max_points)
	var ideal_moves = possible_moves.filter(func(move): return move.points == max_points)
	return get_random_move_from_moves(ideal_moves).card_placements


func get_spawn_chance() -> float:
	var front_row_fill : float = board.get_front_enemies().size()
	var back_row_fill : float = board.get_back_enemies().size()
	var turn = combat.turn
	var spawn_chance := 0.0
	
	spawn_chance += stats.spawn_chance_by_front_row_fill.sample(front_row_fill / board.width)
	spawn_chance += stats.spawn_chance_by_back_row_fill.sample(back_row_fill / board.width)
	spawn_chance += stats.spawn_chance_by_turn.sample(turn / stats.max_turn)
	return spawn_chance


func get_randomised_target_colums() -> Array[int]:
	var spawn_chance := get_spawn_chance()
	var back_row = board.get_enemy_back_row()
	var front_row_card_count := board.get_front_enemies().size()
	var back_row_card_count := board.get_back_enemies().size()
	var total_enemy_cards = front_row_card_count + back_row_card_count
	var target_columns : Array[int] = []
	
	if back_row_card_count >= stats.max_back_row_enemies:
		return []

	for i in range(back_row.size()):
		if back_row[i] != null or rng.randf_range(0, 1) > spawn_chance:
			continue
		target_columns.push_back(i)
	while back_row_card_count + target_columns.size() < stats.min_back_row_enemies:
		var try_insert_idx = rng.randi() % back_row.size()
		if back_row[try_insert_idx] != null or try_insert_idx in target_columns:
			continue
		target_columns.push_back(try_insert_idx)
		
	while back_row_card_count + target_columns.size() > stats.max_back_row_enemies:
		target_columns.remove_at(rng.randi() % target_columns.size())
	return target_columns


func get_random_move_from_moves(moves: Array[Move]):
	var total_weight = 0.0
	
	for move in moves:
		total_weight + move.get_chance_weight()
	
	var hit = rng.randf_range(0, total_weight)
	var weight_idx = 0.0
	for move in moves:
		weight_idx += move.get_chance_weight()
		if hit < weight_idx:
			return move
	return moves.back()


func get_possible_moves_rec(card_count, current_combi, res, added_card = null):
	if added_card != null:
		current_combi.append(added_card)
	if current_combi.size() >= card_count:
		res.append(current_combi)
		return
	for card in available_cards:
		get_possible_moves_rec(card_count, current_combi.duplicate(), res, card)


func get_possible_moves(target_columns : Array[int]) -> Array[Move]:
	var res : Array[Move] = []
	var combis = []
	get_possible_moves_rec(target_columns.size(), [], combis)
	for combi in combis:
		var possible_move = Move.new()
		var i = 0
		for card in combi:
			possible_move.card_placements.append(CardPlacement.new(target_columns[i], card))
			i += 1
		res.append(possible_move)
	return res



class Move:
	var card_placements : Array[CardPlacement]
	var points := 0.0

	func get_chance_weight():
		var weight = 0
		for placement in card_placements:
			weight += placement.card.spawn_frequency
		return weight

class CardPlacement:
	var target_column := 0
	var card : CardData
	
	func _init(column, card_to_play):
		target_column = column
		card = card_to_play
