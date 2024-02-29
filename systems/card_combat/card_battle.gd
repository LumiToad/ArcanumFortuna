class_name CardBattle
extends Control

signal player_turn_ended
signal block_lifted
signal finished(remaining_health : int)

var player_data : PlayerData


## Each turn consits of the phases in the order they appear here
@export var phases : Array[CombatPhase] = []

## Will be used as the intital phase
@export var phase_idx = 0
@export var phase_end_delay = 0.5

@export_category("Debug")
@export var show_current_phase_text := true
@export var is_debug : bool
@export var is_tutorial : bool #sorry....
@export var tutorial_health := 7
@export var debug_player_data : PlayerData
@export var debug_enemy_data : DebugEnemyData

@onready var game_board : GameBoard = $GameBoard
@onready var player : CardPlayer = $CardPlayer
@onready var enemy : EnemyPlayer = $EnemyPlayer

#var enemy_board : Array[Array]
#var board_width : int = 5
var is_battle_over = false
var turn = 0
var is_blocked := false :
	set(value):
		if value == false:
			block_lifted.emit()
		is_blocked = value
	get:
		return is_blocked


func _ready():
	SfxBg._playTrack(SfxBg.MapTypes.CITY)
	SfxOther._SFX_EnterLevel()
	ScreenFade.fade_in(1.0)
	GlobalLog.set_context(GlobalLog.Context.COMBAT)
	GlobalLog.add_entry(name + " loaded.")
	lock_player_actions()
	if is_debug:
		await get_tree().process_frame # game_board needs to be ready first lol
		init(debug_player_data, debug_enemy_data)
		start_combat()
	if is_tutorial:
		await get_tree().process_frame # game_board needs to be ready first lol
		init(debug_player_data.duplicate(), debug_enemy_data.duplicate())
		start_combat()
		enemy.set_health(tutorial_health)


func _exit_tree():
	for phase : CombatPhase in phases:
		phase.reset()


func init(player_data, enemy_data):
	self.player_data = player_data
	player.init(player_data)
	if  enemy_data is EnemyData: 
		enemy_data.init()
		enemy_data.setup_brain(enemy, self)
	enemy.init(enemy_data)
	for phase in phases:
		phase.init(self)


func _input(event):
	if not OS.has_feature("no-cheat") && event.is_action_pressed("debug_quit"):
		finished.emit(player.health)


func _on_active_cards_changed(source, block = true):
	if block:
		is_blocked = true
	var active_cards = game_board.get_active_cards()
	for card : CombatCard in active_cards:
		await card.trigger_keywords(source, card, ActivatedKeyword.Triggers.ON_ACTIVE_CARDS_CHANGED, \
				self, {"active_cards": active_cards})
	if block:
		await get_tree().process_frame
		is_blocked = false


func _on_card_played(new_card : CombatCard):
	is_blocked = true
	await _on_active_cards_changed(new_card, false)
	var active_cards = game_board.get_active_cards()
	await new_card.trigger_keywords(new_card, new_card, ActivatedKeyword.Triggers.ON_PLAYED, \
				self, {"active_cards": active_cards})
	await get_tree().process_frame
	new_card.drag_started.connect($CardDeletion._on_card_drag_started)
	new_card.drag_ended.connect($CardDeletion._on_card_drag_ended)
	is_blocked = false


func start_combat():
	process_next_phase()


func process_next_phase():
	if Pause.is_game_paused():
		await Pause.game_continued
	if show_current_phase_text:
		$CurrentPhaseLabel.text = "Current Phase: \n" + \
		phases[phase_idx].get_class_name()
	phases[phase_idx].execute()
	match await phases[phase_idx].completed:
		CombatPhase.ExitState.ABORT:
			return
		_:
			pass
	_on_phase_completed()


func _on_phase_completed():
	if is_blocked:
		await block_lifted
	await get_tree().create_timer(phase_end_delay).timeout
	phase_idx += 1
	if phase_idx >= phases.size():
		turn += 1
		phase_idx = 0
		%EndTurnAnimation.play_backwards()
	process_next_phase()


func lock_player_actions():
	player.set_active(false)
	%EndTurnButton.disabled = true
	for card in game_board.get_friendly_cards():
		card.is_drag_enabled = false


func unlock_player_actions():
	for card in game_board.get_friendly_cards():
		card.is_drag_enabled = true
	player.set_active(true)
	%EndTurnButton.disabled = false


func _on_end_turn_button_pressed():
	SfxOther._SFX_Coin()
	player_turn_ended.emit()
	%EndTurnAnimation.play()


func handle_attacks(attacker, column, is_source_friendly):
	for offset in await attacker.get_target_offsets():
		if not is_instance_valid(attacker):
			break
		await try_attack(attacker, column + offset, is_source_friendly)


func try_attack(attacker, column_idx, friendly = false) -> bool:
	if Pause.is_game_paused():
		await Pause.game_continued
	if column_idx < 0 or column_idx >= game_board.width:
		return false
	game_board.highlight_tile(column_idx, friendly)
	for card : CombatCard in game_board.get_active_cards():
		await card.trigger_keywords(attacker, card, ActivatedKeyword.Triggers.ON_ATTACK_ATTEMPTED, \
				self, {"target_column": column_idx})
	
	var target = game_board.get_target(column_idx, friendly)
	var was_target_player = target is CardPlayer or target is EnemyPlayer
	var was_lethal = await attacker.animate_attack(target, column_idx, game_board.get_tile(column_idx, friendly))
	if was_lethal:
		if was_target_player:
			finished.emit(player.health)
			if not is_tutorial:
				is_battle_over = true
		else:
			await _on_active_cards_changed(target)
			await target.trigger_keywords(attacker, target, ActivatedKeyword.Triggers.ON_DEATH, self)
			await target.process_death()
	else:
		target.restore_default_color()
	if attacker.health <= 0:
		await _on_active_cards_changed(attacker)
		await attacker.trigger_keywords(target, attacker, ActivatedKeyword.Triggers.ON_DEATH, self)
		await attacker.process_death()
	else:
		attacker.restore_default_color()
	
	game_board.end_tile_highlight(column_idx, friendly)
	await get_tree().process_frame
	return true


func handle_enemy_attacks():
	for i in range(game_board.enemy_tiles_front.get_child_count()):
		if game_board.enemy_tiles_front.get_child(i).get_child_count() == 0:
			continue
		await handle_attacks(game_board.enemy_tiles_front.get_child(i).get_child(0), i, false)
		if is_battle_over:
			return


func handle_friendly_attacks():
	for i in range(game_board.player_tiles.get_child_count()):
		if game_board.player_tiles.get_child(i).get_child_count() == 0:
			continue
		await handle_attacks(game_board.player_tiles.get_child(i).get_child(0), i, true)
		if is_battle_over:
			return



func _on_end_turn_button_mouse_entered():
	SfxOther._SFX_UIButtonHover()
