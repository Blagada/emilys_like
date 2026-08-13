extends Node2D
class_name CounterFoodItem

@export var aliment_scene: PackedScene
@export var level_manager: LevelComponent
@export var positions_container: Node2D


func _ready() -> void:
	var slots: Array[Node] = _get_all_markers() # Récupère la liste des slots (Slot1, Slot2...)
	var level_menu: LevelMenu = _get_level_menu()
	
	_get_foods_menu(level_menu, slots)


func _get_all_markers() -> Array[Node]:
	return positions_container.get_children()


func _get_level_menu() -> LevelMenu:
	if level_manager and level_manager.level_data:
		return level_manager.level_data.level_menu
	return null


func _get_foods_menu(level_menu: LevelMenu, slots: Array[Node]) -> void:
	if level_menu and aliment_scene:
		var foods: Array[FoodData] = level_menu.available_foods

		for i in range(foods.size()):
			if i >= slots.size():
				break

			var slot_node = slots[i]
			var food_marker = slot_node.get_node("FoodMarker") as Marker2D
			var interaction_marker = slot_node.get_node("InteractionPoint") as Marker2D
			var food_data = foods[i]

			# 1. Instanciation
			var food_instance = aliment_scene.instantiate() as FoodItem
			food_instance.food_data = food_data

			# 2. Ajout sur le comptoir
			food_marker.add_child(food_instance)

			# 3. On applique la position de marche personnalisée
			if food_instance.interaction_component and interaction_marker:
				food_instance.set_interaction_point(interaction_marker.global_position)
