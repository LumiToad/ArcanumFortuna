extends Node

@export var node_map_path : NodePath


func init(rng_seed, rng_text):
	get_node(node_map_path).init(rng_seed, rng_text)
