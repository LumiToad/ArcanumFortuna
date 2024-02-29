class_name TriggerSwitch
extends SwitchKeyword

@export_category("Condition")

## The Condition is met when the keyword was triggerd this often
@export var required_trigger_count := 1
@export var dynamic_tooltip_unit_name := "times"

var trigger_count_lookup : Dictionary

func init():
	if description.count('%d') == 1:
		description = description % required_trigger_count
	elif description.count('%d') == 2:
		description = description % [required_trigger_count, required_trigger_count]
	super.init()


func get_dynamic_description(owner: Card):
	return " (%d %s left.)" % [(trigger_count_lookup[owner] if owner in trigger_count_lookup else required_trigger_count), \
			dynamic_tooltip_unit_name]


func trigger(source, owner, target, icon_to_animate, params={}):
	await super(source, owner, target, icon_to_animate, params)
	if not owner in trigger_count_lookup:
		trigger_count_lookup[owner] = max(1, required_trigger_count)
	trigger_count_lookup[owner] -= 1
	if trigger_count_lookup[owner] == 0:
		await _on_completed(owner, icon_to_animate)
