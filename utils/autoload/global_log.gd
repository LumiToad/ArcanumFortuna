extends Node

signal entry_added(text)

enum Context {
	MENU,
	NODEMAP,
	COMBAT
}

var entries : Array[Entry] = []
var context := Context.MENU
var file = null:
	get:
		if file == null:
			file = FileAccess.open("user://logs/custom.log", FileAccess.WRITE)
			if file == null:
				push_error("Custom Log File Open Error: ", FileAccess.get_open_error())
		return file


func set_context(new_context : Context):
	context = new_context
	if OS.has_feature("web") || file == null:
		return
	file.store_line("Entered context " + str(context))

func add_entry(text : String):
	entries.push_back(Entry.new(context, text))
	entry_added.emit(text)
	if OS.has_feature("web") || file == null:
		return
	file.store_line(text)


func get_entry_texts_by_context(context : Context, most_recent_only = true) -> Array[String]:
	var hits = []
	entries.reverse()
	for entry : Entry in entries:
		if entry.context == context:
			hits.push_back(entry.text)
		elif most_recent_only:
			break
	entries.reverse()
	return hits


class Entry:
	var context := Context.MENU
	var text := ""
	
	func _init(context : Context, text : String):
		self.context = context
		self.text = text
