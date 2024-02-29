class_name Player 
extends Control

@export var startNode: EventNode
@export var startData: PlayerData
@export var mouse_track := 0.2
#@export var setup_nodes : Array[Node]

@export var enable_camera_control := false
@export var position_offset := Vector2(5, -55)

@export_category("Debug")
@export var is_debug := false

var data: PlayerData
var targetNode: EventNode
var lerp_weight := 0.1

static var instance : Player

func _ready():
	if instance == null:
		instance = self
	if not enable_camera_control:
		$Camera2D.queue_free()
	global_position = startNode.global_position
	data = startData.duplicate(true)
	update_target(startNode)
	#for node in setup_nodes:
		#if node.has_method("setup_player_data"):
			#node.setup_player_data(data)


func update_target(new_target: EventNode):
	if targetNode:
		targetNode.isCurrent = false
		targetNode.player = null
	targetNode = new_target
	targetNode.isCurrent = true
	targetNode.player = self


func _process(delta):
	
	if targetNode:
		var target = targetNode.position
		position = position.lerp(target - get_rect().size / 2 + position_offset, lerp_weight)
	
	if enable_camera_control:
		$Camera2D.position = $Camera2D.position.lerp(get_viewport().get_mouse_position() * mouse_track, 0.05)
	debug_movement()

var debug_movement_on := false
var debug_position := Vector2()
var debug_speed := 1.0


func debug_movement():
	if not is_debug:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		debug_movement_on = not debug_movement_on
	
	if Input.is_action_just_pressed("ui_page_up"):
		debug_speed = clampf(debug_speed * 2.0, 1.0, 50.0)
	
	if Input.is_action_just_pressed("ui_page_down"):
		debug_speed = clampf(debug_speed * 0.5, 1.0, 50.0)
	
	if debug_movement_on:
		var movement = Vector2(
				Input.get_axis("move_left", "move_right"),
				Input.get_axis("move_up", "move_down")
		)
		
		debug_position += movement * debug_speed
		global_position = debug_position
	else:
		debug_position = global_position
