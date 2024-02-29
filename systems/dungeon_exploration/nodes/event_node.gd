@tool
class_name EventNode extends Control

signal activated(EventNode)
signal completed(EventNode)

var isCurrent := false
@export var connectsTo: Array[EventNode]
var connectedFrom: Array[EventNode] = []
@export_range(0, 10) var lookahead := 2
var currentLookahead = 0

@export_category("Gameplay Options")
@export var event: PackedScene
## How much the enemy level should increase after the event completed
@export var level_gain := 0.0
## Should the scene be switched to the event scene instead of awaiting the event?
@export var is_scene_switch := false

@export_category("Display Options")

@export var defaultColor := Color.WHITE
@export var pickedColor := Color.YELLOW
@export var disabledColor := Color.GRAY
@export var highlightedColor := Color.BLUE
@export var width := 5.0
@export var dashed_width := 3.0
@export var offset := 2.0

var selectable = false
var player: Player
var selectedNode: EventNode
var is_hovered = false
var eventInProgress := false
var passed = false
var seed = 0
static var nodes_counter := 0


func _ready():
	if get_parent().has_method("_on_node_activated"):
		activated.connect(get_parent()._on_node_activated)
	if get_parent().has_method("_on_node_completed"):
		completed.connect(get_parent()._on_node_completed)
	if not Engine.is_editor_hint():
		nodes_counter += 1
		name += "+" + str(nodes_counter)
	$background/icon.visible = false
	for n in connectsTo:
		n.connectedFrom.append(self)

func init(_level: int, _rng: RandomNumberGenerator):
	return


func _generated(node_index: int, _level: int, _rng: RandomNumberGenerator):
	init(_level, _rng)


func _on_mouse_entered():
	if selectable:
		SfxOther._SFX_UIButtonHover()
	is_hovered = true


func _on_mouse_exited():
	is_hovered = false


func _process(delta):
	if selectable or Engine.is_editor_hint() or true:
		$background/icon.visible = true
	
	for node in connectsTo:
		if not is_instance_valid(node):
			continue
		
		if isCurrent:
			selectable = false
			node.player = player
			node.selectable = not eventInProgress
		
		if passed:
			node.selectable = false
	
	if passed:
		passed = false
	
	queue_redraw()


func _input(event: InputEvent):
	if (
			is_hovered
			and event.is_action_pressed("pickUpCard")
			and selectable
		):
		click()


func get_required_color():
	if is_hovered and selectable:
		return pickedColor
	if selectable:
		return defaultColor
	return disabledColor


func click():
	SfxOther._SFX_UIButtonPress()
	activated.emit(self)
	GlobalLog.set_context(GlobalLog.Context.NODEMAP)
	GlobalLog.add_entry("went to " + name)
	player.update_target(self)
	for c in connectedFrom:
		c.passed = true
	
	eventInProgress = true
	await _trigger_event()
	eventInProgress = false
	completed.emit(self)


func _trigger_event():
	var test_instance = event.instantiate()
	print(test_instance)
	if test_instance is RunEndScreen:
		var end_screen = SceneHandler.add_ui_element(event) as RunEndScreen
		end_screen.init(120, self)
		end_screen.setup()
		return
	if not event:
		return
	if is_scene_switch:
		SceneHandler.change_scene(event)
		return
	var instance = event.instantiate()
	if "seed" in instance:
		instance.seed = seed
	instance.trigger(player.data, null)
	await instance.finished


func _draw():
	if connectsTo.size() == 0:
		return
	for node in connectsTo:
		var target = node.position + (node.get_rect().size * Vector2(1, -1)) / 2 - position
		var direction = target.normalized()
		draw_dashed_line(direction * offset, target - direction * offset, node.get_required_color(), node.width, node.dashed_width, true)
