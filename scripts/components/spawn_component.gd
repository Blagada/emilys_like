extends Node2D
class_name SpawnComponent

signal group_spawned(entities: Array[Customer])

@export var entity_scene: PackedScene # Scène Customer
# Liste de toutes les ressources CustomerData (doivent être glisser dans l'inspecteur)
@export var spawn_data_list: Array[CustomerData]

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
	
	# 2. Choisi le look pour le type choisi
	var chosen_visual: CustomerVisual = chosen_type.possible_customers.pick_random()
	
	# 3. Choisir la taille du groupe (1 à 4)
	var group_size: int = randi_range(1, 4)
	print("Entité : ", chosen_type.group_type, " ", chosen_visual, " ", group_size)
	
	# 4. Spawner les personnages
	var group: Array[Customer] = []

	for i: int in range(group_size):
		var new_entity: Customer = entity_scene.instantiate() as Customer
		add_child(new_entity)
		
		# On initialise le client avec le look et les stats choisis
		new_entity.setup(chosen_visual, chosen_type)
		
		# Petit décalage pour ne pas qu'ils se superposent
		new_entity.position.x += i * 40
		group.append(new_entity) # On ajoute le client au tableau

	group_spawned.emit(group) # On envoie le groupe au LevelComponent
