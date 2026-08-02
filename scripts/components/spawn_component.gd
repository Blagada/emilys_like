extends Node2D
class_name SpawnComponent

signal group_spawned(entities: Array[Customer])

@export var entity_scene: PackedScene # Scène Customer
# Liste de toutes les ressources CustomerData (doivent être glisser dans l'inspecteur)
@export var spawn_parent: Node2D
@export var spawn_point: Marker2D

var spawn_data_list: Array[CustomerData] = []
var _valid_types: Array[CustomerData] = []


func set_spawn_data(data_list: Array[CustomerData]) -> void:
	spawn_data_list = data_list
	_refresh_valid_types()


func _refresh_valid_types() -> void:
	_valid_types = []
	for data: CustomerData in spawn_data_list:
		if data.possible_customers.size() > 0:
			_valid_types.append(data)
		else:
			push_warning("Le type ", data.group_type, " n'a pas de visuels définis, il sera ignoré.")


func spawn_entity(forced_group_size: int = -1) -> void:
	if _valid_types.is_empty():
		return
	
	# Si aucune taille de groupe n'est spécifiée, on en tire une aléatoirement (1 à 4)
	if forced_group_size == -1:
		forced_group_size = randi_range(1, 4)
	
	# 4. Spawner les personnages
	var group: Array[Customer] = []

	# On choisit un type de client (VIP, Calm, Normal, Press) pour le groupe
	var chosen_type: CustomerData = _valid_types.pick_random()

	for i: int in range(forced_group_size):
		var new_entity: Customer = entity_scene.instantiate() as Customer
		var parent: Node2D = spawn_parent if spawn_parent else self
		parent.add_child(new_entity)
				
		# --- CHOIX INDIVIDUEL POUR CE CLIENT ---
		# Choisit un visuel individuel 
		# (totalement aléatoire parmi ses possibles -> type de client)
		var chosen_visual: CustomerVisual = chosen_type.possible_customers.pick_random()

		# On initialise le client avec ses propres caractéristiques
		new_entity.setup(chosen_visual, chosen_type)
		
		# Positionnement du spawn sur le marker avec un décalage
		new_entity.global_position = spawn_point.global_position + Vector2(i * 40, 0)
		group.append(new_entity)

	group_spawned.emit(group) # On envoie le groupe au LevelComponent


func spawn_single_customer() -> Customer:
	if _valid_types.is_empty():
		return null

	var chosen_type: CustomerData = _valid_types.pick_random()
	var chosen_visual: CustomerVisual = chosen_type.possible_customers.pick_random()

	var new_entity: Customer = entity_scene.instantiate() as Customer
	var parent: Node2D = spawn_parent if spawn_parent else self
	parent.add_child(new_entity)

	new_entity.setup(chosen_visual, chosen_type)
	new_entity.global_position = spawn_point.global_position

	return new_entity
