class_name Keyword
extends Resource

@export var title := "Keyword"
@export_multiline var description := "Gives your card an ability and stuff"
@export var icon : Texture
@export var emission_icon : Texture
@export var highlight_duration := 0.5


func init():
	pass


func get_dynamic_description(_owner: Card):
	return ""


func animate_keyword_particle(owner: CombatCard):
	await owner.animate_icon(icon)
