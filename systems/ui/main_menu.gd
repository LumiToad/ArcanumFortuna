extends Control

@export var node_map_scene : PackedScene
@export var tutorial_scene : PackedScene
@export var options_scene : PackedScene
@export var credits_scene : PackedScene
@export var seed_popup_data : UIPopupData

var node_map
var seed_text : String
var seed := 0


func _ready():
	SfxBg._playTrack(SfxBg.MapTypes.SPRING)
	node_map = node_map_scene.instantiate()
	randomize()
	seed = randi()
	seed_text = str(seed)
	GlobalLog.set_context(GlobalLog.Context.MENU)
	GlobalLog.add_entry("Main Menu loaded.")
	ScreenFade.fade_in(1.0, false)


func _process(delta):
	visible = !SceneHandler.ui_container.get_child_count() > 0
	# I know this is bad, but Week 10
	# Please do not kill me, I am little good boy,
	# take care of me, need food
	# (will be changed)


func receive_result(result):
	if result is String:
		seed_text = result
		generate_seed(result)
		_on_start_button_button_up()


func generate_seed(text : String):
	seed = 0
	for i in range(text.length()):
		seed += text.unicode_at(i)


func start_game():
	node_map.init(seed, seed_text)
	GlobalLog.add_entry("Seed used: " + seed_text)
	Pause.can_pause = true
	SceneHandler.change_scene(node_map)


func start_tutorial():
	Pause.can_pause = true
	SceneHandler.change_scene(tutorial_scene)
	var tutorial : CardBattle = SceneHandler.current_scene
	SceneHandler.combat = tutorial


func _on_start_button_button_up():
	ScreenFade.fade_out(1.0, true, true)
	ScreenFade.fade_out_complete.connect(start_game)


func _on_tutorial_button_button_up():
	ScreenFade.fade_out(1.0, true, true)
	ScreenFade.fade_out_complete.connect(start_tutorial)


func _on_options_button_button_up():
	var options = options_scene.instantiate() as OptionsMenu
	options.init(1, self)
	options.setup()
	SceneHandler.add_ui_element(options)


func _on_custom_seed_button_button_up():
	var popup = SceneHandler.add_ui_element(seed_popup_data.ui_popup_line_edit_path) as UILineEditPopup
	popup.init(0, self)
	pass


func _on_credits_button_button_up():
	var credits = credits_scene.instantiate() as CreditsScreen
	credits.init(1, self)
	credits.setup()
	SceneHandler.add_ui_element(credits)


func _on_quit_button_button_up():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
