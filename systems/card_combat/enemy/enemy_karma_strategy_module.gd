class_name EnemyKarmaStrategyModule
extends EnemyBrainStrategyModule

@export var karma_goal := 5

func add_points_to_possible_moves(possible_moves, combat : CardBattle):
	var base_potential_karma = combat.enemy.karma
	for card in combat.game_board.get_front_enemies():
		base_potential_karma += card.cost
	for move in possible_moves:
		var potential_karma : float = base_potential_karma
		var karma_gain = 0.0
		for placement in move.card_placements:
			karma_gain += placement.card.cost
		potential_karma += karma_gain
		if karma_goal == 0.0:
			potential_karma += 1.0
		var adjusted_goal = karma_goal + 1.0 if karma_goal == 0.0 else karma_goal
		if potential_karma < 0:
			adjusted_goal += abs(potential_karma)
			potential_karma = 0.01
		var goal_percantage : float = potential_karma / adjusted_goal
		var points_to_add = points_relative_to_goal.sample(goal_percantage * curve_x_target)
		move.points += points_to_add
