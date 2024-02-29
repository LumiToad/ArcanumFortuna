class_name OldEnemyData extends Resource

@export_category("Card Pool")
@export var level1_cards : Array[CardData]
@export var level2_cards : Array[CardData]
@export var level3_cards : Array[CardData]

@export_category("Stats")
@export var gold_reward := 4
@export var stats_per_level : Array[EnemyStats]

@export_category("Debug")
@export var level = 0
@export var rng_seed := 0

var rng := RandomNumberGenerator.new()
var row_width = 5
var stats : EnemyStats 
var rows : Array[Array] = []
var health = -1


func init():
	rng.seed = rng_seed
	if level >= stats_per_level.size():
		push_warning("Enemy Level was set to ", str(level), \
			" but no stats are set above level ", stats_per_level.size() - 1, ".")
		level = stats_per_level.size() - 1
	stats = stats_per_level[level]
	health = stats.min_health + rng.randi() % (stats.max_health - stats.min_health + 1) 


func increase_level():
	if level == stats_per_level.size() - 1:
		push_warning("Level Up has no effect: Enemy is already at max level.")
		return
	level += 1
	stats = stats_per_level[level]


func get_random_card_from_pool(card_pool : Array[CardData]):
	var total_chance = 0
	var hit_value = 0
	for card : CardData in card_pool:
		total_chance += card.spawn_frequency
	var hit = rng.randf_range(0, total_chance)
	for card : CardData in card_pool:
		hit_value += card.spawn_frequency
		if hit <= hit_value:
			return card


func get_random_card() -> CardData:
	var total_freqeuncy = stats.card_level_1_frequency + \
		stats.card_level_2_frequency + stats.card_level_3_frequency
	var hit = rng.randf_range(0, total_freqeuncy)
	if hit <= stats.card_level_1_frequency:
		return get_random_card_from_pool(level1_cards)
	elif hit <= stats.card_level_1_frequency + stats.card_level_2_frequency:
		return get_random_card_from_pool(level2_cards)
	return get_random_card_from_pool(level3_cards)


func get_rows():
	if rows == []:
		fill_rows()
		GlobalLog.add_entry("Enemy Rows created:")
		for row in rows:
			var row_str = "["
			for i in range(row.size()):
				row_str += row[i].name if row[i] is CardData else "null"
				if i < row.size() - 1:
					row_str += ", \t"
			row_str += "]"
			GlobalLog.add_entry(row_str)
	return rows


func fill_rows():
	var total_enemies : int = 0
	for y in range(stats.max_row):
		rows.push_back([])
		for x in range(row_width):
			var spawn_chance = stats.spawn_chance_by_row.sample((y + 1.0) / stats.max_row)
			rows[y].push_back(null if rng.randf_range(0, 1) > spawn_chance else get_random_card())
		var enemy_count_in_row = row_width - rows[y].count(null)
		while enemy_count_in_row < stats.min_enemies_per_row:
			var target_column = rng.randi() % row_width
			if rows[y][target_column] != null:
				continue
			rows[y][target_column] = get_random_card()
			enemy_count_in_row += 1
		while enemy_count_in_row > stats.max_enemies_per_row:
			var target_column = rng.randi() % row_width
			if rows[y][target_column] == null:
				continue
			rows[y][target_column] = null
			enemy_count_in_row -= 1
		total_enemies += enemy_count_in_row
		if total_enemies >= stats.max_total_enemies:
			break
	if total_enemies < stats.min_total_enemies:
		fill_rows_to_fit_total_min(total_enemies, stats.min_total_enemies)
	elif total_enemies > stats.max_total_enemies:
		clear_rows_to_fit_total_max(total_enemies, stats.max_total_enemies)

func clear_rows_to_fit_total_max(current_total, total_max):
	for y in range(stats.max_row):
		for x in range(row_width):
			if current_total <= total_max:
				return
			var despawn_chance = 1.0 - stats.spawn_chance_by_row.sample((y + 1.0) / stats.max_row)
			if despawn_chance <= rng.randf_range(0, 1):
				rows[y][x] = null
				current_total -= 1
	if current_total > total_max:
		clear_rows_to_fit_total_max(current_total, total_max)


func fill_rows_to_fit_total_min(current_total, total_min):
	for y in range(stats.max_row):
		for x in range(row_width):
			if current_total >= total_min:
				return
			var spawn_chance = stats.spawn_chance_by_row.sample((y + 1.0) / stats.max_row)
			if spawn_chance <= rng.randf_range(0, 1):
				rows[y][x] = get_random_card()
				current_total += 1
	if current_total < total_min:
		fill_rows_to_fit_total_min(current_total, total_min)
	
