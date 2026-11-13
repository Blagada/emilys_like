extends Resource
class_name TableData

@export_group("Règles de commande")
@export var allowed_food_types: Array[GameEnums.FoodType] = [] # vide = tous les types

@export_group("Délais")
@export var cleaning_duration: float = 3.0
@export var serving_delay: float = 0.5

@export_group("Apparence")
@export var table_texture: AtlasTexture
@export var chair_texture: AtlasTexture
