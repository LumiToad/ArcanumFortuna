extends CanvasLayer

signal finished
@export_file("*.tscn") var main_menu_scene = ""


func _ready():
	GlobalLog.set_context(GlobalLog.Context.MENU)
	GlobalLog.add_entry(name + " loaded.")
	$Panel/btn_quit.disabled = true
	$Panel/btn_restart.disabled = true
	$Panel/btn_main_menu.disabled = true
	await get_tree().process_frame
	$Panel/btn_quit.disabled = false
	$Panel/btn_restart.disabled = false
	$Panel/btn_main_menu.disabled = false

func trigger(player_data: PlayerData, enemy_data: EnemyData):
	pass


func quit():
	get_tree().quit()


func restart():
	get_tree().current_scene = SceneHandler.current_scene
	get_tree().reload_current_scene()


func _on_btn_main_menu_button_down():
	SceneHandler.change_scene(main_menu_scene)
