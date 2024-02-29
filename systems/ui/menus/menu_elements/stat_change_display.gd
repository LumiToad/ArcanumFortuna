class_name StatsChangeDisplay
extends Control


func setup(from : Buff):
	%KeywordLabel.text = %KeywordLabel.text % from.get_creator_name()
	%OwnerLabel.text = %OwnerLabel.text % from.get_owner_name()
	%KeywordIcon.texture = from.created_by.icon
	%AttackChangeLabel.text = ("+" if from.attack_gain >= 0 else "") + str(from.attack_gain)
	%HealthChangeLabel.text = ("+" if from.health_gain >= 0 else "") + str(from.health_gain)


func setup_as_base_stat(attack : int, health: int, owner_name : String):
	%KeywordLabel.text = %KeywordLabel.text % owner_name
	%OwnerLabel.text = %OwnerLabel.text % "Base Stats"
	%KeywordIcon.hide()
	%AttackChangeLabel.text =  str(attack)
	%HealthChangeLabel.text = str(health)
