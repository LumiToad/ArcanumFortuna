class_name EnemyStats extends Resource

@export_category("Card Frequency")
@export var card_level_1_frequency : float
@export var card_level_2_frequency : float
@export var card_level_3_frequency : float

@export_category("Spawn chance")
@export var max_row : int
@export var spawn_chance_by_row : Curve

@export_category("Spawn Limits")
@export var min_enemies_per_row : int
@export var max_enemies_per_row : int
@export var min_total_enemies : int
@export var max_total_enemies : int

@export_category("Health")
@export var min_health : int
@export var max_health : int
