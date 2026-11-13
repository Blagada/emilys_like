# counter_slot.gd
extends Node2D
class_name CounterSlot

@export var accepted_types: Array[GameEnums.FoodType] = [GameEnums.FoodType.PREPARED]
@export var food_marker: Marker2D
@export var interaction_point: Marker2D

var current_food: FoodItem = null

func is_available() -> bool:
	return current_food == null
