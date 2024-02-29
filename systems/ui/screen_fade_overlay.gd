class_name ScreenFadeOverlay
extends CanvasLayer

signal fade_in_complete
signal fade_out_complete
signal tint_complete

const BLACK_TRANSPARENT = Color(0, 0, 0, 0)

var tween : Tween
var fail_save_timer : SceneTreeTimer
var tween_trans = Tween.TRANS_LINEAR
var tween_ease = Tween.EASE_IN_OUT
var fade_in_color = BLACK_TRANSPARENT
var fade_out_color = Color.BLACK
var color_rect : ColorRect
var is_tween_running := false

func _ready():
	tween = get_tree().create_tween()
	color_rect = $ColorRect


func set_current_tween_trans(tween_trans : Tween.TransitionType):
	self.tween_trans = tween_trans


func set_current_tween_ease(tween_ease : Tween.EaseType):
	self.tween_ease = tween_ease


func set_fade_in_color(color : Color):
	fade_in_color = color


func set_fade_out_color(color : Color):
	fade_out_color = color


func set_is_mouse_blocked(value : bool):
	if value:
		color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func fade_in(duration: float, force_fade : bool = true, block_mouse : bool = false):
	await get_tree().process_frame
	if not force_fade and is_tween_running:
		return
	tween.kill()
	tween = get_tree().create_tween()
	set_is_mouse_blocked(block_mouse)
	setup_tween_internal()
	tween.tween_property(color_rect, "color", fade_in_color, duration).from_current()
	is_tween_running = true
	tween.finished.connect(emit_fade_in_complete_internal)
	fail_save_timer = get_tree().create_timer(duration + 5.0)
	fail_save_timer.timeout.connect(fail_save)


func fade_out(duration : float, force_fade : bool = true, block_mouse : bool = false):
	if not force_fade and is_tween_running:
		return
	await get_tree().process_frame
	tween.kill()
	tween = get_tree().create_tween()
	set_is_mouse_blocked(block_mouse)
	setup_tween_internal()
	tween.tween_property(color_rect, "color", fade_out_color, duration).from_current()
	is_tween_running = true
	tween.finished.connect(emit_fade_out_complete_internal)
	fail_save_timer = get_tree().create_timer(duration + 5.0)
	fail_save_timer.timeout.connect(fail_save)


func restore_default():
	tween_trans = Tween.TRANS_LINEAR
	tween_ease = Tween.EASE_IN_OUT
	fade_in_color = BLACK_TRANSPARENT
	fade_out_color = Color.BLACK
	set_is_mouse_blocked(false)
	setup_tween_internal()


func tint_screen(tint_color : Color, opacity : float, duration : float):
	await get_tree().process_frame
	tween.kill()
	tween = get_tree().create_tween()
	opacity = clampf(opacity, 0.0, 1.0)
	tint_color.a = opacity
	setup_tween_internal()
	tween.tween_property(color_rect, "color", tint_color, duration).from_current()
	is_tween_running = true
	fail_save_timer = get_tree().create_timer(duration + 5.0)
	fail_save_timer.timeout.connect(fail_save)


func reset_tint(duration : float):
	await get_tree().process_frame
	tween.kill()
	tween = get_tree().create_tween()
	var color = BLACK_TRANSPARENT
	setup_tween_internal()
	tween.tween_property(color_rect, "color", color, duration).from_current()
	is_tween_running = true
	fail_save_timer = get_tree().create_timer(duration + 5.0)
	fail_save_timer.timeout.connect(fail_save)


func emit_tint_complete_internal():
	tint_complete.emit()
	reset_screenfade_internal()


func emit_fade_out_complete_internal():
	fade_out_complete.emit()
	reset_screenfade_internal()


func emit_fade_in_complete_internal():
	fade_in_complete.emit()
	reset_screenfade_internal()


func reset_screenfade_internal():
	tween.finished.disconnect(emit_tint_complete_internal)
	tween.finished.disconnect(emit_fade_out_complete_internal)
	tween.finished.disconnect(emit_fade_in_complete_internal)
	is_tween_running = false
	set_is_mouse_blocked(false)


func setup_tween_internal():
	if not tween_trans or not tween_ease:
		push_error("ERROR! tween_trans: ", tween_trans, " tween_ease: ", tween_ease, " one of them is null!")
		return
	tween.set_trans(tween_trans)
	tween.set_ease(tween_ease)


func fail_save():
	if color_rect.color.a == 1.0:
		color_rect.color = BLACK_TRANSPARENT
