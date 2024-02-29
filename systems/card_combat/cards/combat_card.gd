class_name CombatCard 
extends Card

signal deleted(card : CombatCard)
signal animation_finished
signal drag_started
signal drag_ended(card)


@export_category("Animation Settings")
@export var attack_speed = 0.2
@export var attack_rewind = 0.3
@export var attack_delay = 0.1
@export var karma_delay = 1.0
@export var attacked_color : Color
@export var death_color := Color.DARK_RED
@export var highlight_color : Color
@export var active_color : Color
@export var move_speed = 0.5
@export var damage_dealt := preload("res://systems/effects/damage_effect.tscn")

static var held_card : CombatCard

var is_picked_up = false
var is_deletion_queued := false

var target_offsets : Array[int] = [0]
var is_enemy := false
var tile_coordinate := Vector2i(-1, -1)

var placed_position: Vector2

var is_drag_enabled = false
var drag_offset := Vector2.ZERO
var __is_animating := false
var is_animating: bool:
	set(new_value):
		__is_animating = new_value
	get:
		for keyword_slot in %KeyWordSlots.get_children():
			if keyword_slot.get_child(0).is_animating:
				return true
		return __is_animating


func setup():
	super.setup()
	for keyword_slot in %KeyWordSlots.get_children():
		keyword_slot.get_child(0).animation_finished.connect(check_if_animations_finished)
	
	#if card_data.sound_effect:
		#%SFXCard.SFX_CardSignature = card_data.sound_effect
		#%SFXCard._SFX_Signature()


func make_enemy():
	is_enemy = true


func trigger_keywords(source, owner, trigger : int, combat = null, params = {}):
	var keyword_copy = keywords.duplicate()
	for i in range(keyword_copy.size()):
		if keyword_copy[i] is ActivatedKeyword and keywords[i].triggers & trigger:
			await keyword_copy[i].trigger(source, owner, keyword_copy[i].get_target(source, owner, combat), \
					get_node("KeyWordSlots").get_child(i).get_child(0), params)


func check_if_animations_finished():
	if not is_animating:
		animation_finished.emit()


func reverse():
	%Artwork.flip_v = !%Artwork.flip_v


func get_target_offsets():
	placed_position = global_position
	target_offsets = [0]
	for i in range(keywords.size()):
		if not keywords[i] is ActivatedKeyword and keywords[i].has_method("get_new_targets"):
			target_offsets = await keywords[i].get_new_targets(target_offsets, self)
	return target_offsets


#region damage functions

func heal(amount : int):
	pass


func take_damage(amount : int, source = null):
	for keyword in keywords:
		if keyword.has_method("get_reduced_damage"):
			amount = keyword.get_reduced_damage(self, amount)
	if amount <= 0:
		return 0
	GlobalLog.add_entry("'%s' at position %d-%d was dealt %d damage!" % \
	[card_data.name, tile_coordinate.x, tile_coordinate.y, amount])
	health -= amount
	modulate = attacked_color if amount > 0 else active_color
	await animate_damage(amount)
	await trigger_keywords(source, self, ActivatedKeyword.Triggers.ON_TAKE_DAMAGE, null, {"taken_damage": amount})
	return amount


func animate_damage(amount):
	var effect = damage_dealt.instantiate()
	effect.setup(amount)
	get_parent().add_child(effect)
	effect.global_position = global_position + get_rect().size / 2
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", rotation + deg_to_rad(-5), 0.2)
	tween.tween_property(self, "rotation", rotation, 0.1)
	tween.play()


func restore_default_color():
	modulate = Color.WHITE
	$Health.modulate = Color.WHITE
	$Attack.modulate = Color.WHITE
	$Cost.modulate = Color.WHITE


func process_death() -> bool:
	if health <= 0:
		modulate = death_color
		SfxOther._SFX_DestroyCard()
		await get_tree().process_frame
		play_animation("die")
		await get_tree().create_timer(1).timeout
		print("Card '", card_name, "' died!")
		GlobalLog.add_entry("'%s' at position %d-%d died!" % [card_data.name, tile_coordinate.x, tile_coordinate.y])
		queue_free()
		return true
	restore_default_color()
	return false
#endregion


#func animate_burn():
	#%Artwork.material = delete_material
	#%Cardback.visible = false
	#var random_angle = [-1, -0.5, 0.5, 1, 1.5, 2]
	#random_angle = random_angle[randi_range(0, random_angle.size() - 1)]
	#%Artwork.material.set_shader_parameter("angle", random_angle)
	#var shader_noise : NoiseTexture2D = %Artwork.material.get_shader_parameter("noise")
	#shader_noise.noise.seed = randf_range(0.0, 100.0)
	#%Artwork.material.set_shader_parameter("noise", shader_noise)
	#play_animation("fade_out_icons")
	#var tween = create_tween()
	#tween.tween_method(set_shader_value, -1.0, 2.0, death_delay)
	#await tween.finished
#
#
#func set_shader_value(value: float):
	#%Artwork.material.set_shader_parameter("progress", value);


func animate_attack(target, tile_idx, tile: Control) -> bool:
	var target_position
	var half_card = get_rect().size / 2
	
	if attack <= 0:
		return false
	%SFXCard._SFX_Attack()
	if target is CombatCard:
		target_position = target.global_position
		GlobalLog.add_entry(
				"'%s' at position %d-%d attacked '%s' at position %d-%d." %
				[card_data.name,
				tile_coordinate.x,
				tile_coordinate.y,
				target.card_data.name,
				target.tile_coordinate.x,
				target.tile_coordinate.y])
	else:
		target_position = tile.global_position
		GlobalLog.add_entry(
				"'%s' at position %d-%d attacked empty tile at position %d-%d." %
				[card_data.name,
				tile_coordinate.x,
				tile_coordinate.y,
				tile_idx, 0 if is_enemy else 1
				])
	$Attack.modulate = active_color
	modulate = highlight_color
	
	z_index += 1
	var attack_tween = create_tween()
	attack_tween.set_trans(Tween.TRANS_SINE)
	attack_tween.set_ease(Tween.EASE_IN)
	print("[CombatCard] '%s' started attack tween" % card_name)
	var wait_mod = 0
	if not global_position.is_equal_approx(placed_position):
		attack_tween.tween_property(self, "global_position", placed_position, attack_rewind)
		wait_mod += attack_rewind
	attack_tween.tween_property(self, "global_position", target_position, attack_speed)
	attack_tween.set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "global_position", placed_position, attack_rewind)
	attack_tween.play()
	await attack_tween.finished
	print("[CombatCard] '%s' finished attack tween" % card_name)
	
	var dealt_damage : int = await target.take_damage(attack, self)
	await trigger_keywords(target, self, 32, null, {"damage_dealt": dealt_damage})
	
	if dealt_damage > 0 and not target is CombatCard:
		var effect = damage_dealt.instantiate()
		effect.setup(dealt_damage)
		get_parent().add_child(effect)
		effect.global_position = target_position + half_card
	
	#target.restore_default_color()
	z_index -= 1
	
	var was_lethal = target.health <= 0
	var is_battle_over = false
	if was_lethal and (target is EnemyPlayer or target is CardPlayer):
		is_battle_over = true
	if was_lethal:
		await get_tree().process_frame
		await trigger_keywords(target, self, ActivatedKeyword.Triggers.ON_KILL)
	for keyword in keywords:
		if keyword.has_method("is_disabled"):
			await keyword.animate_keyword_particle(self)
			set_disabled_overlay_visible(keyword.is_disabled(self))
	return was_lethal


func animate_karma(target):
	GlobalLog.add_entry("'%s' at position %d-%d added %d karma."\
			% [card_data.name, tile_coordinate.x, tile_coordinate.y, cost])
	return %KarmaCost


func animate_move(target_pos):
	placed_position = target_pos
	modulate = active_color
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, move_speed)
	tween.play()
	await get_tree().create_timer(move_speed).timeout
	GlobalLog.add_entry("'%s' at position %d-%d moved to positon %d-%d." % 
			[card_data.name,
			tile_coordinate.x,
			tile_coordinate.y,
			tile_coordinate.x,
			tile_coordinate.y - 1
			])
	tile_coordinate = Vector2i(tile_coordinate.x, tile_coordinate.y - 1)
	modulate = Color.WHITE


#region Card deletion
func delete():
	held_card = null
	is_deletion_queued = true
	set_process(false)
	set_process_input(false)
	SfxOther._SFX_DestroyCard()
	await super.animate_burn()
	health = 0
	for i in range(keywords.size()):
		if keywords[i] is ActivatedKeyword and keywords[i].triggers & ActivatedKeyword.Triggers.ON_ACTIVE_CARDS_CHANGED:
			await keywords[i].trigger(self, self, self, \
					get_node("KeyWordSlots").get_child(i).get_child(0))
	await get_tree().process_frame
	deleted.emit(self)
	queue_free()


func _process(delta):
	if is_picked_up:
		global_position = drag_offset + get_global_mouse_position()


func _input(event: InputEvent):
	if is_hovered and event.is_action_released("open_inspection"):
		var new_inspection = inspection.instantiate() as CardInspection
		new_inspection.init(75, self)
		new_inspection.inspection_init(self)
		SceneHandler.add_ui_element(new_inspection)
	
	if not is_drag_enabled:
		return
	
	if event.is_action_pressed("pickUpCard") and not is_picked_up:
		if is_hovered:
			pickup()
	
	if event.is_action_released("pickUpCard") and is_picked_up:
		put(null)
		emit_signal("drag_ended", self)


func pickup():
	%ShowCardTooltip.hide_tooltip()
	%ShowCardTooltip.set_process(false)
	
	is_picked_up = true
	if held_card:
		# Edge case if you pick up multiple cards
		held_card.put(null)
	held_card = self
	drag_offset = global_position - get_global_mouse_position()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	emit_signal("drag_started")


func put(dropNode):
	await get_tree().process_frame
	if is_deletion_queued:
		return
	%ShowCardTooltip.set_process(true)
	is_picked_up = false
	held_card = null
	mouse_filter = Control.MOUSE_FILTER_PASS

	animate_move(placed_position)
#endregion
