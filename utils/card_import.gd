extends Node

@export_file("*.csv") var table 

func _ready():
	import_cards(table)

func import_cards(cards_table):
	var cards_data = load(cards_table)
	for card_data in cards_data.records:
		card_data.ResourceName = card_data.ResourceName.strip_edges()
		var card_path = "res://data/cards/" + card_data.ResourceName + ".tres"
		if not ResourceLoader.exists(card_path):
			push_error("Cannot load card '" + card_data.ResourceName +\
						"': no matching Resource found.")
			continue
		var card_resource : CardData = load(card_path)
		card_resource.name = card_data.Name
		card_resource.cost = card_data.Cost
		card_resource.attack = card_data.Attack
		card_resource.health = card_data.Health
		card_resource.keywords.clear()
		
		for keyword_name in card_data.Keywords.split(';'):
			keyword_name = keyword_name.strip_edges()
			if keyword_name == "":
				continue
			var keyword_path = "res://data/keyword/" + keyword_name + ".tres"
			if not ResourceLoader.exists(keyword_path):
				push_error("Cannot load keyword '" + keyword_name +\
						"': no matching Resource found.")
				continue
			card_resource.keywords.append(load(keyword_path))
		ResourceSaver.save(card_resource, card_path)
		print("Card Resource '", card_data.ResourceName, "' was imported successfully!")
