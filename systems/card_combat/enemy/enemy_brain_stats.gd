class_name EnemyBrainStats extends Resource

@export_category("Spawn chance")
@export var spawn_chance_by_turn : Curve

## Turn after which the spawn chance is capped to the rightmost value
@export var max_turn := 10
@export var spawn_chance_by_front_row_fill : Curve
@export var spawn_chance_by_back_row_fill : Curve

@export_category("Spawn Limits")
#@export var min_front_row_enemies : int
#@export var max_front_row_enemies : int
@export var min_back_row_enemies : int
@export var max_back_row_enemies : int
#@export var min_total_enemies : int
#@export var max_total_enemies : int

@export_category("Health")
@export var min_health : int
@export var max_health : int
