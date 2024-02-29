extends TextureRect

@export var hover_color := Color.GRAY
@export var is_active := false

var default_color : Color
var is_hovered := false


func _ready():
	default_color = modulate

func _on_card_drag_started():
	set_active()


func _on_card_drag_ended(dragged_card: CombatCard):
	var was_deleted = false
	if is_active and is_hovered:
		dragged_card.is_deletion_queued = true
		var tween = create_tween()
		var self_rect = get_global_rect()
		var target_position = self_rect.get_center()
		target_position.y -= self_rect.size.y / 2
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(dragged_card, "global_position", target_position, 0.2)
		await tween.finished
		dragged_card.reparent(self)
		dragged_card.delete()
		was_deleted = true
	set_inactive()


func set_active():
	if $AnimationPlayer.current_animation == "anim_open_card_delete":
		return
	$AnimationPlayer.play("anim_open_card_delete")


func set_inactive():
	if $AnimationPlayer.current_animation == "anim_close_card_delete":
		return
	$AnimationPlayer.play("anim_close_card_delete")


func _on_mouse_entered():
	is_hovered = true
	if not is_active:
		return
	modulate = hover_color


func _on_mouse_exited():
	modulate = default_color
	is_hovered = false
