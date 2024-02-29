@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_tool_menu_item("Import Enemy Decks", try_import_decks)


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass


func try_import_decks():
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = 0
	file_dialog.add_filter("*.csv")
	file_dialog.title = "Choose a decks table to import."
	EditorInterface.get_editor_main_screen().add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(420, 360))
	file_dialog.show()
	file_dialog.file_selected.connect(import_cards)


func import_cards(cards_table):
	var decks_data = load(cards_table)
	for enemy_brain in decks_data.records:
		enemy_brain.ResourceName = enemy_brain.ResourceName.strip_edges()
		var deck_path = "res://data/enemy/" + enemy_brain.ResourceName + ".tres"
		if not ResourceLoader.exists(deck_path):
			push_error("Cannot load deck '" + enemy_brain.ResourceName +\
						"': no matching Resource found.")
			continue
		
		var enemy_resource : EnemyBrain = load(deck_path)
		#enemy_resource.available_cards = enemy_brain.Available_Cards
		enemy_resource.available_cards.clear()
		
		for available_cards in enemy_brain.AvailableCards.split(';'):
			available_cards = available_cards.strip_edges()
			if available_cards == "":
				continue
			var card_path = "res://data/cards/" + available_cards + ".tres"
			if not ResourceLoader.exists(card_path):
				push_error("Cannot load cards '" + available_cards +\
						"': no matching Resource found.")
				continue
			enemy_resource.available_cards.append(load(card_path))
		ResourceSaver.save(enemy_resource, deck_path)
		print("Card Resource '", enemy_brain.ResourceName, "' was imported successfully!")
