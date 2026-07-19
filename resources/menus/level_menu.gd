extends Resource
class_name LevelMenu

@export var available_foods: Array[FoodData] = []

func get_random_food() -> FoodData:
	if available_foods.is_empty():
		return null
	return available_foods.pick_random()
