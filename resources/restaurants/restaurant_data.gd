extends Resource
class_name RestaurantData

@export var restaurant_name: String
@export var restaurant_desc: String
@export var service_duration: float = 60.0 # Durée d'un service (ex: Dîner) en sec
@export var sitting_animation_delay: float = 0.3 # Temps pour s'asseoir
@export var max_waiting_customers: int = 4 # Nombre de place pour attendre
@export var levels: Array[LevelData] # Ajout des ressources de niveau pour ce resto

@export_group("Fenêtre")
@export var window_backgrounds: Dictionary[GameEnums.WeatherState, PackedScene] = {}
