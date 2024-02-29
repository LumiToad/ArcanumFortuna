extends TutorialAction

@export_file("*.tscn") var scene := ""

func _execute():
	SceneHandler.change_scene(scene)
