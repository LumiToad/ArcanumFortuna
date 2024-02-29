@tool
extends EventNode

@export var potential_events : Array[RandomScene]

var level := 0

var index
var rng : RandomNumberGenerator
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


func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	var replacement_event := RandomScene.get_random_from(potential_events)
	if not replacement_event:
		return
	event = replacement_event.scene
	$background/icon.texture = replacement_event.placeholder_icon_texture


func _trigger_event():
	var selected_enemy = null
	
	if not event:
		return
	if is_scene_switch:
		SceneHandler.change_scene(event)
		return
	var instance = event.instantiate()
	if instance is BattleEvent:
		instance.seed = combat_seed
		var enemy_pool = instance.potential_enemies.filter(func(enemy): 
			return (enemy.max_level < 0 or level <= enemy.max_level) and level >= enemy.min_level)
		selected_enemy = enemy_pool[rng.randi_range(0, len(enemy_pool) - 1)]
		selected_enemy.level = level
		selected_enemy.rng_seed = combat_seed
		player.data.draw_rng_seed = draw_seed
		player.lerp_weight = 0.01
		ScreenFade.fade_out(1.0, true, true)
		await ScreenFade.fade_out_complete
		player.lerp_weight = 0.1
		
	elif "seed" in instance:
		instance.seed = combat_seed
	if instance.has_method("trigger"):
		instance.trigger(player.data, selected_enemy)
	await instance.finished


