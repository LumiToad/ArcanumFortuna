extends EventBase

@export var healthOptions: Array[int]
@export var templateCard: PackedScene
@export var seed := 0
var player_data_ref: PlayerData
var rng = RandomNumberGenerator.new()


func _ready():
	rng.seed = seed


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	super(player_data, enemy_data)
	player_data_ref = player_data
	print("using seed " + str(seed))
		
	if not is_inside_tree():
		await tree_entered

	var opts = healthOptions.duplicate(true)
	
	for i in range(len(opts)):
		print(rng.state)
		await get_tree().create_timer(.5).timeout
		var opt = opts.pop_at(rng.randi_range(0, len(opts) - 1))
		
		var card = templateCard.instantiate()
		card.set_value(opt)
		$CanvasLayer/Control/Hand.add_child(card)
		
		card.clicked.connect(card_clicked)
		$AudioStreamPlayer.play()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for c in $CanvasLayer/Control/Hand.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_STOP


func card_clicked(card: Card):
	$CanvasLayer/Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in $CanvasLayer/Control/Hand.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.isHovered = false
		if c == card:
			continue
		c.queue_free()
	
	await card.reveal()
	
	await get_tree().create_timer(2).timeout
	player_data_ref.health += card.value
	finished.emit()
	queue_free()
