class_name ShowTooltip
extends Control

@export_category("Tooltip Settings")
@export var icon: Texture2D
@export var title := "Tooltip"
@export_multiline var text := "Lorem Ipsum... dolor sit amet..."
@export var tooltip_template : PackedScene = preload("res://systems/ui/tooltips/tooltip_basic.tscn")
@export var offset := Vector2.ZERO
@export_subgroup("Trigger Settings")
@export_flags("Hover Duration", "Right-Click") var trigger_mode := 0b11
@export var hover_min_duration := 0.5

var is_hovered := false
var instance: TooltipBase = null:
	set(value): instance = create_instance(value)

static var tooltip_container = null

@onready var cooldown := hover_min_duration


func _process(delta):
	if is_hovered:
		cooldown -= delta
	else:
		cooldown = hover_min_duration
		hide_tooltip()
	
	if is_hovered:
		show_tooltip()


func _exit_tree():
	hide_tooltip()


func create_instance(value):
	if value == null:
		return null
	var new_instance = value as TooltipBasic
	new_instance.setup(title, icon, text)
	return new_instance


func show_tooltip():
	if not tooltip_container:
		tooltip_container = CanvasLayer.new()
		tooltip_container.name = "tooltip_container"
		tooltip_container.layer = 120
		SceneHandler.add_ui_element(tooltip_container)
	
	if not instance:
		instance = tooltip_template.instantiate()
		tooltip_container.add_child(instance)
		instance.global_position = get_global_mouse_position() + offset


func hide_tooltip():
	if instance != null:
		instance.queue_free()
		instance = null


func _on_mouse_entered():
	is_hovered = true


func _on_mouse_exited():
	is_hovered = false
