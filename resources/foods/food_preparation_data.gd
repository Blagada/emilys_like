@tool
extends Resource
class_name FoodPreparationData

const COOKS: Array = [
	GameEnums.FoodType.SAUTE,
	GameEnums.FoodType.OVEN,
	GameEnums.FoodType.PIZZA_OVEN,
	GameEnums.FoodType.GRIDDLE
]

const CAN_BURN: Array = [
	GameEnums.FoodType.OVEN,
	GameEnums.FoodType.PIZZA_OVEN,
	GameEnums.FoodType.GRIDDLE
]

const COMBO: Array = [
	GameEnums.FoodType.COMBO,
	GameEnums.FoodType.PIZZA_OVEN,
	GameEnums.FoodType.GRIDDLE
]

const VISIBLE_FOR: Dictionary = {
	"cook_time": COOKS,
	"burn_delay": CAN_BURN,
	"burned_sprite": CAN_BURN,
	"stir_interval": [GameEnums.FoodType.SIMMER],
	"overflow_cleanup_time": [GameEnums.FoodType.SIMMER],
	"ingredients": COMBO,
}

@export var type: GameEnums.FoodType = GameEnums.FoodType.PREPARED:
	set(value):
		type = value
		notify_property_list_changed()


@export_group("Délai de préparation")
@export var preparation_time: float = 1.0 # manipulation (mettre au four, sortir, poser sur le tray), hors cuisson

@export_group("Temps de cuisson")
@export var cook_time: float = 0.0
@export var burn_delay: float = 0.0
@export var burned_sprite: Texture2D

@export_group("Mijoté")
@export var stir_interval: float = 0.0
@export var overflow_cleanup_time: float = 0.0

@export_group("Combo")
@export var ingredients: Array[FoodData] = []

func _validate_property(property: Dictionary) -> void:
	if not VISIBLE_FOR.has(property.name):
		return
	if not type in VISIBLE_FOR[property.name]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
