extends Node2D
class_name CounterFoodItem

@export var aliment_scene: PackedScene
@export var level_manager: LevelComponent
@export var positions_container: Node2D


func _ready() -> void:
	var slots: Array[Node] = _get_all_markers()
	var level_menu: LevelMenu = _get_level_menu()
	
	_populate_foods_menu(level_menu, slots)


func _get_all_markers() -> Array[Node]:
	return positions_container.get_children()


func _get_level_menu() -> LevelMenu:
	if level_manager and level_manager.level_data:
		return level_manager.level_data.level_menu
	return null


func _populate_foods_menu(level_menu: LevelMenu, slots: Array[Node]) -> void:
	if not level_menu or not aliment_scene:
		return

	var foods: Array[FoodData] = level_menu.available_foods
	var used_slots: Array[Node] = []

	for food_data in foods:
		# 1. On cherche un slot libre compatible avec ce type d'aliment
		var slot_node = _find_compatible_slot(slots, used_slots, food_data)

		if slot_node == null:
			push_warning("Aucun slot disponible ou compatible trouvé pour : " + food_data.name)
			continue

		used_slots.append(slot_node)

		# Position de l'aliment
		var food_marker = slot_node.get_node("FoodMarker") as Marker2D
		# Position du player pour préparer l'aliment
		var interaction_marker = slot_node.get_node("InteractionPoint") as Marker2D

		# 2. Instanciation
		var food_instance = aliment_scene.instantiate() as FoodItem
		# Va chercher l'information de l'aliment dans food_data
		food_instance.food_data = food_data

		# 3. Ajout sur le comptoir
		food_marker.add_child(food_instance)

		# 4. On applique la position de marche personnalisée
		if food_instance.interaction_component and interaction_marker:
			food_instance.set_interaction_point(interaction_marker.global_position)


# Fonction qui valide le type de slot et le type d'aliment. Si compatible, l'aliment s'affiche dans ce slot
func _find_compatible_slot(slots: Array[Node], used_slots: Array[Node], food_data: FoodData) -> Node:
	for slot in slots:
		if slot in used_slots:
			continue

		# Le slot doit être un CounterSlot et accepter le type de cet aliment
		if slot is CounterSlot and food_data.type in slot.accepted_types:
			return slot

	# Si le slot n'est pas vide, on assigne rien
	return null
