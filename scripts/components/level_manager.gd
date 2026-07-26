extends Node
class_name LevelComponent

@export var tray_places: TrayComponent
@export var customer_spawner: SpawnComponent
@export var level_menu: LevelMenu
@export var payment_queue: PaymentQueueComponent
@export var earnings_gauge: EarningsGauge

@export var daily_goal: float = 100.0
@export var expert_threshold_percent: float = 150.0 # % du goal pour "expert"
@export var sitting_animation_delay: float = 0.3

@onready var spawn_button: Button = $"../../ZoneFixe/SpawnButton"

func _ready():
	earnings_gauge.setup(daily_goal, expert_threshold_percent)

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
			table_comp.order_component.all_orders_served.connect(_on_all_orders_served.bind(table_comp))


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
			assigned_table.order_component.seated_customers.append(customer)
			assigned_table.is_dirty = true
			assigned_table.order_component.total_bill = 0.0
			customer.move_to_table(seats[i], assigned_table.global_position)
		_handle_group_ordering(assigned_table, group)


func _handle_group_ordering(assigned_table: TableComponent, group: Array[Customer]) -> void:
	for customer: Customer in group:
		if not customer.movement_component.has_arrived():
			await customer.movement_component.destination_reached

	await get_tree().create_timer(sitting_animation_delay).timeout
	for customer: Customer in group:
		customer.change_state(GameEnums.CustomerState.WAITING_TO_ORDER)
	assigned_table.order_component.show_thinking()

	var order_delay: float = 500.0 / group[0].customer_data.speed
	await get_tree().create_timer(order_delay).timeout

	for customer: Customer in group:
		var food: FoodData = level_menu.get_random_food()
		customer.set_order(food)
		assigned_table.order_component.total_bill += food.price
		customer.change_state(GameEnums.CustomerState.ORDERING)
		print(customer.name, " commande : ", customer.current_order.resource_path)

	assigned_table.order_component.update_order_bubble()


func _on_all_orders_served(table: TableComponent) -> void:
	table.current_state = GameEnums.TableState.IN_MEAL
	var customers: Array[Customer] = table.order_component.seated_customers

	for customer: Customer in customers:
		customer.change_state(GameEnums.CustomerState.EATING)

	var eating_delay: float = 800.0 / customers[0].customer_data.speed
	await get_tree().create_timer(eating_delay).timeout

	for customer: Customer in customers:
		customer.change_state(GameEnums.CustomerState.WAITING_FOR_PAYMENT)

	table.order_component.show_dirty()
	table.current_state = GameEnums.TableState.WAITING_FOR_PAYMENT
	payment_queue.enqueue(customers[0], table)


# TODO : BOUTON TEST. À effacer lorsque les clients entreront aléatoirement dans le restaurant
func _on_spawn_button_pressed() -> void:
	# Appelle ton spawn avec un groupe aléatoire pour tester
	# var random_size = randi_range(1, 4)
	customer_spawner.spawn_entity()
