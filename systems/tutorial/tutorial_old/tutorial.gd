class_name Tutorial
extends CardBattle

@export var enemy_data: OldEnemyData
@export var tutorial_steps: Node
@export_file("*.tscn") var next_scene := ""

var current_step: int = 0
var current_step_ref: TutorialStep = null

signal turn_started
signal turn_completed

# Called when the node enters the scene tree for the first time.
func _ready():
	init(debug_player_data.duplicate(true), enemy_data.duplicate(true))
	current_step -= 1
	if tutorial_steps == null:
		tutorial_steps = self
	next_step()


func _process(delta):
	if current_step_ref:
		if current_step_ref.is_completed():
			if tutorial_steps.get_child_count() > current_step + 1:
				next_step()


func next_step():
	if tutorial_steps.get_child_count() <= current_step + 1:
		push_error("No more steps available.")
		return
	current_step += 1
	current_step_ref = tutorial_steps.get_child(current_step) as TutorialStep
	current_step_ref.do_actions()
	current_step_ref.setup_conditions()



func _on_end_turn_button_button_down():
	pass


func _on_skip_button_button_down():
	get_tree().change_scene_to_file(next_scene)
