extends EventBase

@export var base_gold_to_reward := 0


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	super(player_data, enemy_data)
	player_data.currency += base_gold_to_reward + enemy_data.gold_reward
	$AnimationPlayer.animation_finished.connect(func(_w): finished.emit())
	$AnimationPlayer.play("present")
