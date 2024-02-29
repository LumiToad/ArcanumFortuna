@tool
class_name CombatNode
extends EventNode


var level := 0

var index
var rng
var combat_seed := 0
var draw_seed := 0


func init(level: int, rng: RandomNumberGenerator):
	self.rng = rng
	self.level = level
	combat_seed = rng.randi()
	draw_seed = rng.randi()


func _generated(node_index: int, _level: int, _rng: RandomNumberGenerator):
	index = node_index
	init(_level, _rng)


func _trigger_event():
	var instance = event.instantiate() as BattleEvent
	instance.seed = combat_seed
	var enemy_pool = instance.potential_enemies.filter(func(enemy): 
		return (enemy.max_level < 0 or level <= enemy.max_level) and level >= enemy.min_level)
	var selected_enemy = enemy_pool[rng.randi_range(0, len(enemy_pool) - 1)]
	selected_enemy.level = level
	selected_enemy.rng_seed = combat_seed
	player.data.draw_rng_seed = draw_seed
	instance.trigger(player.data, selected_enemy)
	await instance.finished
