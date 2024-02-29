extends EventBase

@export var events: Array[PackedScene]

var seed = 0
var event_queue = []
var player_data_ref
var enemy_data_ref


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	player_data_ref = player_data
	enemy_data_ref = enemy_data
	for event in events:
		var instance = event.instantiate()
		if "seed" in instance:
			instance.seed = seed
		event_queue.append(instance)
		instance.finished.connect(event_finished)
	
	event_finished()


func event_finished():
	if event_queue.size() <= 0:
		finished.emit()
		queue_free()
		return
	var event = event_queue.pop_front()
	add_child(event)
	event.trigger(player_data_ref, enemy_data_ref)
