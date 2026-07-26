extends Node2D
class_name SpawnComponent

signal group_spawned(entities: Array[Customer])

@onready var spawn_point: Marker2D = $SpawnPoint

@export var entity_scene: PackedScene # Scène Customer
# Liste de toutes les ressources CustomerData (doivent être glisser dans l'inspecteur)
@export var spawn_data_list: Array[CustomerData]
@export var spawn_parent: Node2D

var _valid_types: Array[CustomerData] = []

func _ready() -> void:
	# On filtre la liste au démarrage pour ne garder que les types complets
	_valid_types = []
	for data: CustomerData in spawn_data_list:
		if data.possible_customers.size() > 0:
			_valid_types.append(data)
		else:
			push_warning("Le type ", data.group_type, " n'a pas de visuels définis, il sera ignoré.")
			
	# TODO : Appel de test pour voir si ça fonctionne au démarrage, va devoir être sorti dans la mécanique de spawn des clients
	spawn_entity()

func spawn_entity() -> void:
	if _valid_types.is_empty():
		return

	# 1. Choisi un type parmi ceux qui ont des visuels associés
	var chosen_type: CustomerData = _valid_types.pick_random()
	
	# 2. Choisi le look pour le type choisi (aléatoire)
	var chosen_visual: CustomerVisual = chosen_type.possible_customers.pick_random()
	
	# 3. Choisir la taille du groupe (1 à 4)
	var group_size: int = randi_range(1, 4)
	print("Entité : ", chosen_type.group_type, " ", chosen_visual, " ", group_size)
	
	# 4. Spawner les personnages
	var group: Array[Customer] = []

	for i: int in range(group_size):
		var new_entity: Customer = entity_scene.instantiate() as Customer
		var parent: Node2D = spawn_parent if spawn_parent else self
		parent.add_child(new_entity)
		
		# On initialise le client avec le look et les stats choisis
		new_entity.setup(chosen_visual, chosen_type)
		
		# Positionnement du spawn sur le marker
		new_entity.global_position = spawn_point.global_position + Vector2(i * 40, 0)
		group.append(new_entity) # On ajoute le client au tableau

	group_spawned.emit(group) # On envoie le groupe au LevelComponent
