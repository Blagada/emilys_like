extends Node
class_name OrderFlowComponent

@export_group("Scripts")
@export var customer_spawner: SpawnComponent
@export var payment_queue: PaymentQueueComponent
@export var day_cycle: DayCycleComponent

@export_group("Variables")
@export var sitting_animation_delay: float = 0.3

@onready var level_manager: LevelComponent = get_tree().get_first_node_in_group("LevelManager")

func _ready() -> void:
	customer_spawner.group_spawned.connect(_on_customer_group_spawned)

	for table_node: Node in get_tree().get_nodes_in_group("Table"):
		var table_comp = table_node.get_node_or_null("TableComponent")
		if table_comp:
			table_comp.order_component.all_orders_served.connect(_on_all_orders_served.bind(table_comp))


# --- GESTION DE L'ARRIVÉE D'UN GROUPE DE CLIENTS ---
func _on_customer_group_spawned(group: Array[Customer]) -> void:
	var all_tables: Array[Node] = get_tree().get_nodes_in_group("Table")
	var group_size: int = group.size()

	var assigned_table: TableComponent = TableAssignmentService.choose_table(all_tables, group_size)

	if assigned_table == null:
		return

	var seats: Array[Marker2D] = assigned_table.reserve_seats(group_size)

	if seats.size() == group_size:
		for i: int in range(group_size):
			var customer: Customer = group[i]
			assigned_table.order_component.seated_customers.append(customer)
			assigned_table.is_dirty = true
			assigned_table.order_component.total_bill = 0.0
			customer.move_to_table(seats[i], assigned_table.global_position)
			day_cycle.register_customer_spawned()
		_handle_group_ordering(assigned_table, group)


# --- DÉROULEMENT DE LA COMMANDE À TABLE ---
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
		var food: FoodData = level_manager.level_data.level_menu.get_random_food()
		customer.set_order(food)
		assigned_table.order_component.total_bill += food.price
		customer.change_state(GameEnums.CustomerState.ORDERING)
		customer.patience_component.start(customer.customer_data.patience)
		customer.patience_component.patience_expired.connect(
			_on_group_patience_expired.bind(group, assigned_table)
		)

	assigned_table.order_component.update_order_bubble()


# --- FIN DU SERVICE DES PLATS (PASSAGE AU REPAS) ---
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


func _on_group_patience_expired(group: Array[Customer], table: TableComponent) -> void:
	for customer: Customer in group:
		customer.patience_component.cancel()

	CustomerExitService.release_table(table)

	for customer: Customer in group:
		_send_customer_away(customer)


func _send_customer_away(customer: Customer) -> void:
	await CustomerExitService.send_customer_to_exit(customer, payment_queue.exit_marker)
	payment_queue.customer_exited.emit()
