class_name BattleEvent
extends EventBase

@export var potential_enemies: Array[EnemyData]
@export var battleField: PackedScene
@export var winEvent: PackedScene
@export var loseEvent: PackedScene

var pauseMovement := true
var hideMap := true
var seed := 0

func trigger(player_data: PlayerData, enemy_data: EnemyData):
	super(player_data, enemy_data)
	
	var field = battleField.instantiate()
	$CanvasLayer.add_child(field)
	SceneHandler.combat = field
	#field.is_debug = false
	field.init(player_data.duplicate(true), enemy_data.duplicate(true))
	field.start_combat()
	
	var remainingLife = await field.finished
	var won = remainingLife > 0
	
	if won:
		SteamService.try_unlock_achievement("Better than Noyan")
	
	player_data.health = remainingLife
	
	var event = winEvent if won else loseEvent
	
	if event:
		var instance = event.instantiate()
		if instance is RunEndScreen:
			instance.queue_free()
			instance = SceneHandler.add_ui_element(loseEvent)
			instance.init(110, self)
			instance.setup()
			field.queue_free()
			finished.emit()
			queue_free()
			return
		if "seed" in instance:
			instance.seed = seed
		add_child(instance)
		instance.trigger(player_data, enemy_data)
		await instance.finished
		#battle_ends
		ScreenFade.fade_out(1.0)
		await ScreenFade.fade_out_complete
		ScreenFade.fade_in(1.0)
	
	field.queue_free()
	finished.emit()
	queue_free()
