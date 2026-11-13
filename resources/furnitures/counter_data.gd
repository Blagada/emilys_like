extends Resource
class_name CounterData

@export_group("Règles de commande")
@export var allowed_food_types: Array[GameEnums.FoodType] = [
	GameEnums.FoodType.PREPARED,
	GameEnums.FoodType.DRINK,
	GameEnums.FoodType.SIMMER,
	GameEnums.FoodType.COMBO
]

@export_group("Délais de service")
@export var serving_delay: float = 0.5
