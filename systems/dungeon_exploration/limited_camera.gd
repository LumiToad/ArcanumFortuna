extends Camera2D

var limit_rect = null

func _ready():
	for child in get_children():
		if child is ReferenceRect:
			limit_rect = child.get_global_rect()
			apply_limit(limit_rect)
			return


func apply_limit(rect):
	if rect == null:
		return
	limit_top = rect.position.y
	limit_bottom = rect.position.y + rect.size.y
	limit_right = rect.position.x + rect.size.x
	limit_left = rect.position.x
