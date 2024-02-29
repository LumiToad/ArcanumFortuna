extends Node

var current_track: Track
@export var start_track: Track

func _ready():
	if start_track:
		play_track(start_track)


func play_track(track: Track):
	for other_track in get_children():
		if other_track.name == track.name:
			continue
	
	if has_node(track.resource_name):
		var node = get_node(track.resource_name)
		for player in node.get_children():
			player.play()
		return
	
	var node = TrackNode.new(track)
	add_child(node)
	node.play()
