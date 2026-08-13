extends Resource
class_name LevelData

@export var restaurant: RestaurantData
@export var level_number: int = 1

@export_group("Services & Clients")
@export var level_menu: LevelMenu
@export var possible_customers: Array[CustomerData] = []
@export var active_services: Array[GameEnums.ServiceType] = [GameEnums.ServiceType.LUNCH]
@export var tray_max_capacity: int = 3

@export_group("Objectifs & Difficulté")
@export var expert_threshold_percent: float = 150.0

@export_group("Rythme des Spawns")
@export var counter_order_probability_percent: float = 18.0
@export var spawn_interval_jitter_percent: float = 20.0
@export var initial_spawn_delay_min: float = 1.0
@export var initial_spawn_delay_max: float = 2.0
