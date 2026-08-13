extends Resource
class_name RestaurantData

@export var restaurant_name: String
@export var total_levels: int = 10
@export var service_duration: float = 60.0 # Durée d'un service (ex: Dîner) en sec
@export var sitting_animation_delay: float = 0.3 # Temps pour s'asseoir
@export var max_waiting_customers: int = 4 # Nombre de place pour attendre
