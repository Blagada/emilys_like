extends Resource
class_name LevelData

@export var restaurant: RestaurantData
@export var level_number: int = 1
@export var level_menu: LevelMenu
@export var possible_customers: Array[CustomerData]
@export var active_services: Array[GameEnums.ServiceType]
@export var tray_max_capacity: int = 3
