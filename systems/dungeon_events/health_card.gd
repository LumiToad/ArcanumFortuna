extends Card

var data: CardData

var isHovered := false
var selected := false
var value := 0
signal clicked

func _ready():
	mouse_entered.connect(mouse_entered_event)
	mouse_exited.connect(mouse_exited_event)


func set_value(amount):
	value = amount


func _process(delta):
	if isHovered:
		scale = scale.lerp(Vector2.ONE * 1.1, 0.2)
	elif selected:
		scale = scale.lerp(Vector2.ONE * 1.05, 0.2)
	else:
		scale = scale.lerp(Vector2.ONE, 0.2)


func reveal():
	var tween = create_tween()
	tween.tween_property(self, "size", Vector2(0, 1), 1)
	tween.play()
	await tween.finished
	$value.text = str(value)
	$value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$value.size = Vector2(-1, 1)
	tween.kill()
	tween = null
	tween = create_tween()
	tween.play()
	tween.tween_property(self, "size", Vector2(-1, 1) * -1, 1)
	await tween.finished


func initialise(_data: CardData):
	data = _data


func mouse_entered_event():
	isHovered = true
	$HoverSound.play()

func mouse_exited_event():
	isHovered = false


func _input(event):
	if isHovered and event.is_action_pressed("pickUpCard"):
		$ClickSound.play()
		clicked.emit(self)
