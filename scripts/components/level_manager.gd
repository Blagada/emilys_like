extends Node
class_name LevelComponent

@export var tray_places: TrayComponent
@export var customer_spawner: SpawnComponent
@export var level_menu: LevelMenu

@onready var spawn_button: Button = $"../../ZoneFixe/SpawnButton"

func _ready():
	
	# 1. Connexion des aliments
	for food: Node in get_tree().get_nodes_in_group("Food"):
		if food.has_signal("food_clicked"):
			food.food_clicked.connect(tray_places.add_item)
	
	# 2. Connexion du spawn
	if customer_spawner:
		customer_spawner.group_spawned.connect(_on_customer_group_spawned)
		spawn_button.pressed.connect(_on_spawn_button_pressed)

	# 3. Connexion des tables (une seule fois, peu importe combien de groupes les utiliseront)
	for table_node: Node in get_tree().get_nodes_in_group("Table"):
		var table_comp = table_node.get_node_or_null("TableComponent")
		if table_comp:
			table_comp.all_orders_served.connect(_on_all_orders_served.bind(table_comp))
			

func _on_customer_group_spawned(group: Array[Customer]) -> void:
	var all_tables: Array[Node] = get_tree().get_nodes_in_group("Table")
	var group_size: int = group.size()

	# 1. Délègue le choix de table au service dédié (réutilisable sur tous les niveaux)
	var assigned_table: TableComponent = TableAssignmentService.choose_table(all_tables, group_size)

	if assigned_table == null:
		print("--- AUCUNE TABLE DISPONIBLE pour un groupe de ", group_size)
		return

	# 2. Réserve les sièges et assigne les clients
	var seats: Array[Marker2D] = assigned_table.reserve_seats(group_size)

	if seats.size() == group_size:
		for i: int in range(group_size):
			var customer: Customer = group[i]
			assigned_table.seated_customers.append(customer)
			customer.state_changed.connect(_on_customer_seated.bind(customer))
			customer.move_to_table(seats[i], assigned_table.global_position)


func _on_customer_seated(new_state: GameEnums.CustomerState, _target_pos: Vector2, customer: Customer) -> void:
	if new_state != GameEnums.CustomerState.SITTING:
		return

	var order_delay: float = 500.0 / customer.customer_data.speed
	await get_tree().create_timer(order_delay).timeout

	customer.set_order(level_menu.get_random_food())
	print(customer.name, " commande : ", customer.current_order.resource_path)


func _on_all_orders_served(table: TableComponent) -> void:
	for customer: Customer in table.seated_customers:
		_start_eating(customer)


func _start_eating(customer: Customer) -> void:
	customer.change_state(GameEnums.CustomerState.EATING)

	var eating_delay: float = 800.0 / customer.customer_data.speed
	await get_tree().create_timer(eating_delay).timeout

	customer.change_state(GameEnums.CustomerState.WAITING_FOR_PAYMENT)

# TODO : BOUTON TEST. À effacer lorsque les clients entreront aléatoirement dans le restaurant
func _on_spawn_button_pressed() -> void:
	# Appelle ton spawn avec un groupe aléatoire pour tester
	var random_size = randi_range(1, 4)
	customer_spawner.spawn_entity()
