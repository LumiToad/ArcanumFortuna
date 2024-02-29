class_name RandomScene
extends Resource


## Relative chance to be picked, the bigger the number is the more likely this scene is to be choosen over other random scenes
@export var chance_weight := 1
@export var scene : PackedScene
@export var placeholder_icon_texture : Texture
static var rng : RandomNumberGenerator = null


static func init(base_rng):
	rng = RandomNumberGenerator.new()
	rng.seed = base_rng.randi()

static func get_random_from(list: Array[RandomScene]) -> RandomScene:
	if rng == null:
		push_error("RandomScene was called witout being intialised!")
		init(RandomNumberGenerator.new())
	var total_chance_weight := 0
	
	for random_scene in list:
		if random_scene == null:
			continue
		total_chance_weight += random_scene.chance_weight
	var hit := rng.randi_range(1, total_chance_weight)
	var change_weight_index := 0
	for random_scene in list:
		change_weight_index += random_scene.chance_weight
		if change_weight_index >= hit:
			return random_scene
	return list.back() if list.size() > 0 else null
