extends Node
class_name NodeMapGenerator
@export var start_node: EventNode
@export var final_node: PackedScene
@export var max_lanes := 2
@export var split_chance := 0.3
@export var possible_nodes: Array[NodeGenerationsOptions]
@export var rng_seed := 1337
@export var min_lane_length := 2
@export var max_lane_length := 4

@export_category("Nodes Placement")
@export var max_length_between_nodes := 150.0
@export var min_length_between_nodes := 300.0
@export var max_x := 256
@export var min_x := -256
@export var max_distance_between_nodes_x := 256
@export var min_gap_between_lanes := 128

var lanes: Array[NodeMapGenerator] = []
var generated_nodes: Array[EventNode] = []

var reward_odds: float
var rng: RandomNumberGenerator
var rng_seed_text := "1337"

var map_level := 0.0
var current_node_count = 0
var repeat_key = null
var repeat_counter := 0
var challenging_counter := 0
var generation_counters := {}

var reattach: Array[EventNode] = []

signal finished_generating(generated_nodes: Array[EventNode])

static var nodes_counter := 0

func init(rng_seed, rng_text):
	self.rng_seed = rng_seed
	rng_seed_text = rng_text


func _ready():
	if name == "node-map":
		GlobalLog.set_context(GlobalLog.Context.NODEMAP)
		GlobalLog.add_entry(name + " loaded.")
	else:
		name = "side-path"
	nodes_counter += 1
	name += "+" + str(nodes_counter)

func setup():
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	$CanvasLayer/SeedLabel.set_seed(rng_seed_text)


func generate(amount: int) -> void:
	while amount > 0:
		amount -= 1
		var next_node_opts = get_next_node()
		var next_node: EventNode
		if amount == 0 and final_node:
			next_node = final_node.instantiate()
		else:
			next_node = next_node_opts.node_reference.instantiate()
		var prev_node = generated_nodes[-1] if len(generated_nodes) > 0 else start_node
		add_child.call_deferred(next_node)
		var median_position = null
		if len(reattach) > 0:
			var median = Vector2()
			for n in reattach:
				median += n.global_position
			median /= len(reattach)
			median_position = median
		
		next_node._generated(current_node_count, floori(map_level), rng)
		
		current_node_count += 1
		
		next_node.ready.connect(func():
			var prev_node_position = prev_node.global_position
			if median_position:
				prev_node_position = median_position
			next_node.global_position = prev_node_position + Vector2.UP * rng.randf_range(min_length_between_nodes, max_length_between_nodes)
			next_node.global_position.x = rng.randf_range(min_x, max_x)
			next_node.global_position.x = clampf(
				next_node.global_position.x,
				min(prev_node_position.x - max_distance_between_nodes_x, min_x),
				max(prev_node_position.x + max_distance_between_nodes_x, max_x)
			)
		)
		
		if len(reattach) <= 0:
			prev_node.connectsTo.append(next_node)
		
		for node in reattach:
			node.connectsTo.append(next_node)
		
		reattach.clear()
		generated_nodes.append(next_node)
		reward_odds += next_node_opts.reward_modifier
		map_level += next_node_opts.level_modifier
		
		if max_lanes > 0 and amount > max_lane_length * max_lanes:
			if rng.randf() <= split_chance:
				var splitting_node = generated_nodes[-1]
				var lane_generated_nodes = []
				var lane_count = rng.randi_range(2, max_lanes)
				var lengths = []
				var longest = 0
				
				for i in range(lane_count):
					var length = rng.randi_range(
							min_lane_length,
							max_lane_length
						)
					lengths.append(length)
					longest = max(longest, length)
				
				for i in range(lane_count):
					var generator = generate_lane(
							splitting_node,
							i,
							lengths[i],
							longest,
							lane_count
						)
					splitting_node.connectsTo.append(generator.generated_nodes[0])
					lane_generated_nodes.append(generator.generated_nodes)
					current_node_count = max(current_node_count, generator.current_node_count)
				
				generated_nodes.append(splitting_node)
				
				for l in lane_generated_nodes:
					reattach.append(l[-1])
					generated_nodes.append_array(l)
				
				reward_odds /= lane_count
				challenging_counter /= lane_count
				map_level /= lane_count
				for g in generation_counters.keys():
					generation_counters[g] /= lane_count


func generate_lane(
		start_node: EventNode,
		lane_index: int,
		length: int,
		total_lane_length: int,
		total_generated_lanes: int
	) -> NodeMapGenerator:
	
	var lane = NodeMapGenerator.new()
	
	lane.current_node_count = current_node_count
	lane.reward_odds = reward_odds
	lane.max_lanes = 0
	lane.rng = rng
	lane.repeat_counter = repeat_counter
	lane.repeat_key = repeat_key
	lane.map_level = map_level
	lane.challenging_counter = challenging_counter
	
	var width = max_x - min_x
	var total_width = width * total_generated_lanes
	var part_width = total_width / total_generated_lanes
	
	lane.min_x = \
		  ((min_x - total_width / 2) + lane_index * part_width) \
		+ min_gap_between_lanes
	lane.max_x = (lane.min_x + part_width * (lane_index + 1)) - min_gap_between_lanes
	
	lane.min_length_between_nodes = \
		  (lane.min_length_between_nodes \
		* (total_lane_length + 1)) \
		/ (length + 1)
	lane.max_length_between_nodes = \
		  (lane.max_length_between_nodes \
		* (total_lane_length + 1)) \
		/ (length + 1)
	
	lane.possible_nodes = possible_nodes
	lane.start_node = start_node
	
	add_child.call_deferred(lane)
	lane.generate(length)
	
	reward_odds += lane.reward_odds
	map_level += lane.map_level
	challenging_counter += lane.challenging_counter
	
	for g in generation_counters.keys():
		if g in lane.generation_counters:
			generation_counters[g] += lane.generation_counters[g]
	
	for g in lane.generation_counters.keys():
		if not g in generation_counters:
			generation_counters[g] = lane.generation_counters[g]
		else:
			generation_counters[g] += lane.generation_counters[g]
	
	return lane
	

func get_next_node() -> NodeGenerationsOptions:
	var ref = possible_nodes.duplicate()
	
	# Shuffle Nodes List
	var weights = []
	for w in ref:
		weights.append(w.chance)
	
	var shuffled = RNGAdditions.weighted_shuffle(rng, ref, weights)
	
	for n in shuffled:
		if current_node_count < n.min_nodes_from_start:
			continue
		
		if challenging_counter < n.min_challenging_nodes:
			continue
		
		if repeat_key == n:
			if repeat_counter > n.max_repeat:
				continue
		
		if n.min_distance_between > 0:
			if not n in generation_counters:
				generation_counters[n] = -n.min_distance_between
			
			if current_node_count - generation_counters[n] < n.min_distance_between:
				continue
		
		if reward_odds + n.reward_modifier > 0:
			if n.reward_modifier > 0:
				challenging_counter += 1
			else:
				challenging_counter = 0
			if repeat_key == n:
				repeat_counter += 1
			
			repeat_key = n
			
			generation_counters[n] = current_node_count
			return n
	
	challenging_counter += 1
	return ref[0]


func _on_test_shop_button_up():
	var shop = SceneHandler.add_ui_element("res://systems/ui/menus/shop/shop.tscn") as Shop
	shop.init(0, self)
	shop.setup()
