extends Node

var current_scene
@onready var scene_container = $CurrentScene
@onready var shelf = $Shelf
@onready var ui_container = $UIContainer
var combat : CardBattle

func _ready():
	await get_tree().root.ready
	get_tree().current_scene.reparent(scene_container)
	current_scene = get_tree().current_scene


func change_scene(new_scene):
	for child in scene_container.get_children():
		child.queue_free()
	
	for child in shelf.get_children():
		child.queue_free()
	
	for child in ui_container.get_children():
		child.queue_free()
	
	var scene_to_change = get_instantiated_scene(new_scene)
	current_scene = scene_to_change
	scene_container.add_child(current_scene)


func add_shelf_element(element):
	var element_to_add = get_instantiated_scene(element)
	shelf.add_child(element_to_add)


func add_ui_element(element):
	var element_to_add = get_instantiated_scene(element)
	ui_container.add_child(element_to_add)
	return element_to_add


func get_instantiated_scene(element):
	var element_to_add
	if element is PackedScene:
		element_to_add = element.instantiate()
	elif element is Node:
		element_to_add = element
	elif element is String:
		element_to_add = load(element).instantiate()
	
	return element_to_add
