extends Node
class_name LevelComponent

@export var tray_places: TrayComponent
@export var customer_spawner: SpawnComponent

@onready var spawn_button: Button = $"../../ZoneFixe/SpawnButton"

func _ready():
	
	# 1. Connexion des aliments
	for aliment in get_tree().get_nodes_in_group("Food"):
		aliment.food_clicked.connect(tray_places.add_item)
	
	# 2. Connexion du spawn
	if customer_spawner:
		customer_spawner.group_spawned.connect(_on_customer_group_spawned)
		spawn_button.pressed.connect(_on_spawn_button_pressed)

func _on_customer_group_spawned(group: Array):
	var all_tables = get_tree().get_nodes_in_group("Table")
	var group_size = group.size()
	
	# 1. Identifier les tables valides
	var valid_tables = []
	for table_node in all_tables:
		var table_comp = table_node.get_node_or_null("TableComponent")
		if table_comp and table_comp.can_accommodate_group(group_size):
			valid_tables.append(table_comp)
	
	if valid_tables.is_empty():
		print("--- AUCUNE TABLE DISPONIBLE pour un groupe de ", group_size)
		return

	# 2. Filtrer les tables optimales
	var target_capacity = 2 if group_size <= 2 else 4
	var optimal_tables = valid_tables.filter(func(t): 
		return t.all_chair_positions.size() == target_capacity
	)
	
	# Debug : Afficher le pool de sélection
	# print("Tables optimales trouvées (capacité ", target_capacity, ") : ", optimal_tables.size())
	
	var chosen_pool = optimal_tables if not optimal_tables.is_empty() else valid_tables
	
	# 3. Choisir et assigner
	var assigned_table = chosen_pool.pick_random()
	var seats = assigned_table.reserve_seats(group_size)

	# On vérifie juste si la table a bien retourné assez de sièges
	if seats.size() == group_size:
		for i in range(group_size):
			var customer = group[i]
			# Envoie la position des chaises et de la table
			customer.move_to_table(seats[i], assigned_table.global_position)

func _on_spawn_button_pressed():
	# Appelle ton spawn avec un groupe aléatoire pour tester
	var random_size = randi_range(1, 4)
	print("Test : Spawn forcé d'un groupe de ", random_size)
	customer_spawner.spawn_entity()
