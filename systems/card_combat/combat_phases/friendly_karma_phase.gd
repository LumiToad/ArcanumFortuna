class_name FriendlyKarmaPhase
extends CombatPhase

@export var karma_blob = preload("res://assets/vfx/big_blob.tscn")
@export var small_blob = preload("res://assets/vfx/karma_particle.tscn")
@export var karma_duration := 2.3
@export var karma_delay := 0.6
@export var blob_move := 20


static func get_class_name():
	return "Friendly Karma Phase"


func get_corresponding_trigger():
	return CombatPhaseTrigger.SourcePhases.FRIENDLY_KARMA


func _on_karma_decreased(source):
	for card : CombatCard in combat.game_board.get_active_cards():
		for i in range(card.keywords.size()):
			if card.keywords[i] is ActivatedKeyword and card.keywords[i].triggers & 2:
				await card.keywords[i].trigger(source, card, card.keywords[i].get_target(source, card, combat), \
						card.get_node("KeyWordSlots").get_child(i).get_child(0))

func get_relevant_cards():
	return combat.game_board.get_friendly_cards().filter(
			func(card: Card):
				return card.cost != 0
				)


func get_karma_modify_target():
	return combat.player


func process_effect() -> ExitState:
	var relevant_cards = get_relevant_cards()
	if len(relevant_cards) <= 0:
		return ExitState.DEFAULT
	var target = get_karma_modify_target()
	await animate_karma(relevant_cards, target)
	if await target.process_karma_overflow():
		combat.finished.emit(combat.player.health)
		return ExitState.ABORT
	return ExitState.DEFAULT


func animate_karma(relevant_cards, target):
	# Create Blob
	var blob = karma_blob.instantiate()
	combat.game_board.add_child(blob)
	blob.global_position = Vector2(1920 / 2, 1080 / 2)
	
	var total_wait_count = 0.0

	for card : CombatCard in relevant_cards:
		Pause.can_pause = false
		
		var health_slot = await card.animate_karma(target)
		var small_pearl = small_blob.instantiate()
		combat.game_board.add_child(small_pearl)
		small_pearl.global_position = health_slot.get_global_rect().get_center()
		
		await combat.get_tree().create_timer(karma_delay).timeout
		var tween = combat.create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_EXPO)
		
		tween.tween_property(small_pearl, "global_position", blob.original_position, karma_delay)
		
		tween.finished.connect(func():
			blob.update_number(card.cost)
			small_pearl.emitting = false
			small_pearl.queue_free()
			blob.global_position += health_slot.global_position.direction_to(blob.original_position) * blob_move * abs(card.cost)
		)
		
		tween.play()
		
		if card.cost < 0:
			var start_time = Time.get_unix_time_from_system()
			await _on_karma_decreased(card)
			var duration = Time.get_unix_time_from_system() - start_time
			if duration >= karma_duration:
				
				continue
			
			total_wait_count += karma_duration - duration
	
	await combat.get_tree().create_timer(karma_delay).timeout
	
	# Put Blob into player.
	var t = blob.create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_EXPO)
	
	t.tween_property(blob, "global_position", target.get_node("%Karma").global_position + Vector2.DOWN * 30, karma_delay)
	t.tween_property(blob, "scale", Vector2.ZERO, karma_delay)
	
	t.play()
	await combat.get_tree().create_timer(karma_delay).timeout
	target.modify_karma(blob.count)
	SfxOther._SFX_Blip(blob.count)
	blob.delete()
	
	Pause.can_pause = true
