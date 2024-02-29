extends EventBase

@export var possibleCards: Array[CardData]
@export var cardsToReward := 1
@export var cardsToChooseFrom := 3
@export var cardTemplate: PackedScene
@export var seed := 0
@export var card_animation_speed = 0.66
@export var card_interpolation_option := Tween.TRANS_CUBIC

@export_category("Alternative Reward")
## the {placeholder} will get replaced with the actual reward gained.
@export var alternative_reward_string := "You gained {placeholder} coins instead!"
@export var min_coins = 1
@export var max_coins = 10

var rng := RandomNumberGenerator.new()

var pauseMovement := true

var player_data_ref : PlayerData
var selected_cards = []
#var prev_mode: bool = true

func _ready():
	rng.seed = seed
	$CanvasLayer/Control/ConfirmButton.visible = false


func trigger(player_data: PlayerData, enemy_data: EnemyData):
	super(player_data, enemy_data)
	#prev_mode = CardsOverlay.is_available()
	#CardsOverlay.toggle(true)
	if cardsToChooseFrom < cardsToReward:
		push_error("Cards to Choose from is less than the Cards that get rewarded! force adjusting")
		cardsToChooseFrom = cardsToReward
	
	player_data_ref = player_data
	if not is_inside_tree():
		await tree_entered
	var grabbag = possibleCards.duplicate()
	for i in range(cardsToChooseFrom):
		await get_tree().create_timer(.5).timeout
		var c = grabbag.pop_at(rng.randi_range(0, len(grabbag) - 1))
		if c:
			var visualCard = cardTemplate.instantiate() as Card
			visualCard.card_data = c
			visualCard.load_from_data(c)
			visualCard.setup()
			visualCard.deselect()
			$CanvasLayer/Control/Cards.add_child(visualCard)
			visualCard.clicked.connect(card_clicked)
			SfxOther._SFX_Draw()
			visualCard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	%SkipButton.visible = true
	
	for c in $CanvasLayer/Control/Cards.get_children():
		if cardsToChooseFrom == cardsToReward:
			c.clicked.emit(c)
		else:
			c.mouse_filter = Control.MOUSE_FILTER_STOP


func card_clicked(card: Card):
	if card in selected_cards:
		var idx = selected_cards.find(card)
		if idx > -1:
			card.deselect()
			selected_cards.remove_at(idx)
	else:
		# card.select()
		selected_cards.push_back(card)

	while len(selected_cards) > cardsToReward:
		selected_cards[0].deselect()
		selected_cards.pop_front()
	if len(selected_cards) == cardsToReward:
		$CanvasLayer/Control/ConfirmButton.show()
	else:
		$CanvasLayer/Control/ConfirmButton.hide()


func _on_confirm_button_pressed():
	$CanvasLayer/Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer/Control/SkipButton.hide()
	$CanvasLayer/Control/ConfirmButton.hide()
	#CardsOverlay.toggle(prev_mode)
	
	for c : Card in $CanvasLayer/Control/Cards.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.is_hovered = false
		if c in selected_cards:
			player_data_ref.cardStack.push_back(c.card_data.duplicate())
	
	%AnimationPlayer.play("show_deck")
	await %AnimationPlayer.animation_finished
	for c: Card in selected_cards:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(card_interpolation_option)
		tween.tween_property(c, "global_position", %VisualDeck.global_position, card_animation_speed)
		tween.finished.connect(func(): c.queue_free())
		tween.play()
		await get_tree().create_timer(card_animation_speed).timeout
	
	var all_tween = create_tween()
	all_tween.set_parallel(true)
	all_tween.set_ease(Tween.EASE_IN)
	all_tween.set_trans(Tween.TRANS_CUBIC)
	for c : Card in $CanvasLayer/Control/Cards.get_children():
		all_tween.tween_property(c, "global_position", c.global_position + Vector2.UP * 600, card_animation_speed)
		all_tween.finished.connect(func(): if c: c.queue_free())
	all_tween.play()
	
	%AnimationPlayer.play("hide_deck")
	await %AnimationPlayer.animation_finished
	finished.emit()
	queue_free()


func calculate_alternative_reward():
	for i in range(rng.randi_range(min_coins, max_coins)):
		$CanvasLayer/BigBlob.update_number(1)
		$CanvasLayer/BigBlob.global_position += Vector2(randf() - 0.5, randf() - 0.5) * randf_range(100, 200)
		await get_tree().create_timer(0.5).timeout


func get_reward_text(value):
	var string = ""
	if value < 10:
		string += " "
		string += str(value)
		string += " "
	elif value < 100:
		string += str(value)
	else:
		string = str(value)
	return alternative_reward_string.replace("{placeholder}", string)


func _on_skip_button_pressed():
	#CardsOverlay.toggle(prev_mode)
	
	%AnimationPlayer.play("skipped")
	await %AnimationPlayer.animation_finished
	
	await calculate_alternative_reward()
	var reward = $CanvasLayer/BigBlob.count
	$CanvasLayer/skip_reward.text = get_reward_text(0)
	%AnimationPlayer.play("show_reward")
	await %AnimationPlayer.animation_finished
	$CanvasLayer/BigBlob.original_position = $CanvasLayer/skip_reward/big_blob_target.global_position
	await get_tree().create_timer(2).timeout
	$CanvasLayer/BigBlob.delete()
	$CanvasLayer/skip_reward.text = get_reward_text(reward)
	player_data_ref.currency += reward
	await get_tree().create_timer(2).timeout
	
	finished.emit()
	queue_free()
