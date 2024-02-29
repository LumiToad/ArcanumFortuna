extends Control

@export var scenes_to_preload : Array[PackedScene]
@export var karma_particle : PackedScene
@export_file("*.tscn") var main_scene = ""

## The whole purpose of this scene is to preload assets that are going to be used later on in the game.
## After completing this scene should kill itself.

signal complete

func _ready():
	#%ProgressBar.max_value = scenes_to_preload.size()
	#%ProgressBar.value = 0
	await get_tree().create_timer(0.5).timeout
	run()

func run():
	%LoadInfo.show()
	for i in range(scenes_to_preload.size()):
		%LoadInfo.text = "Loading " + \
				scenes_to_preload[i].resource_path + "..."
		%LoadedStorage.add_child(scenes_to_preload[i].instantiate())
		await get_tree().process_frame
	await $ColorRect/ProgressBar/AnimationPlayer.animation_finished
	complete.emit()
	queue_free()
