extends EventBase

func _ready():
	SfxOther._SFX_Win()


func complete():
	queue_free()
	finished.emit()
