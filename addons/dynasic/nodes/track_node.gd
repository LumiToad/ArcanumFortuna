class_name TrackNode
extends Node

var track

func _init(track: Track):
	self.track = track
	self.name = track.name
	
	for layer in track.layers:
		var player = AudioStreamPlayer.new()
		player.stream = layer
		player.name = ".".join(layer.resource_path.split("/")[-1].split(".").slice(0, -1))
		add_child(player)


func play():
	for player: AudioStreamPlayer in get_children():
		player.play()


func pause(new_pause_state: bool):
	for player: AudioStreamPlayer in get_children():
		player.stream_paused = new_pause_state


func stop():
	for player: AudioStreamPlayer in get_children():
		player.stop()
