extends Node
class_name LevelComponent

@export var tray_places: TrayComponent
@export var customer_spawner: SpawnComponent
@export var level_data: LevelData
@export var payment_queue: PaymentQueueComponent
@export var earnings_gauge: EarningsGauge
@export var navigation_region: NavigationRegion2D
@export var level_intro_screen: LevelIntroScreen
@export var day_cycle: DayCycleComponent
@export var day_results_screen: DayResultsScreen
@export var end_of_service_panel: EndOfServicePanel

@export var expert_threshold_percent: float = 150.0 # % du goal pour "expert"
@export var sitting_animation_delay: float = 0.3
@export var counter_order_probability_percent: float = 70.0 # chance qu'un groupe de 1 aille au comptoir
@export var spawn_interval_jitter_percent: float = 20.0
@export var initial_spawn_delay_min: float = 1.0
@export var initial_spawn_delay_max: float = 2.0

@onready var spawn_button: Button = $"../../ZoneFixe/SpawnButton"

var daily_goal: float = 0.0
var expert_goal: float = 0.0
var table_count: int = 0
var total_seats: int = 0
var avg_customer_travel_time: float = 0.0
var avg_customer_speed: float = 0.0
var avg_cleaning_duration: float = 0.0
var avg_cycle_duration: float = 0.0
var _auto_spawning: bool = false
var active_customer_count: int = 0
var _closing_time_reached: bool = false

func _ready():
	customer_spawner.set_spawn_data(level_data.possible_customers)
	TrayManager.current_max_capacity = level_data.tray_max_capacity
	level_intro_screen.visible = true

	# Appel de notre helper pour calculer les métriques proprement
	await _setup_level_metrics()
	_setup_daily_goal()
	
	earnings_gauge.setup(daily_goal, expert_threshold_percent)
	level_intro_screen.setup(level_data, table_count, total_seats, daily_goal, expert_goal)
	level_intro_screen.day_started.connect(_on_day_started)

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


func _setup_level_metrics() -> void:
	var metrics = await LevelMetricsHelper.compute_metrics(navigation_region, customer_spawner, level_data.possible_customers)
	table_count = metrics["table_count"]
	total_seats = metrics["total_seats"]
	avg_customer_travel_time = metrics["avg_customer_travel_time"]
	avg_customer_speed = metrics["avg_customer_speed"]
	avg_cleaning_duration = metrics["avg_cleaning_duration"]


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
			active_customer_count += 1
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
		var food: FoodData = level_data.level_menu.get_random_food()
		customer.set_order(food)
		assigned_table.order_component.total_bill += food.price
		customer.change_state(GameEnums.CustomerState.ORDERING)

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


func _on_day_started() -> void:
	EarningsManager.reset_daily()
	day_cycle.service_started.connect(_on_service_started)
	day_cycle.closing_time.connect(_on_closing_time)
	payment_queue.customer_exited.connect(_on_customer_exited)
	day_cycle.start_day(level_data.active_services)


func _on_service_started(service: GameEnums.ServiceType) -> void:
	print("Service démarré : ", GameEnums.SERVICE_TYPE_LABELS.get(service, "?"))

	if not _auto_spawning:
		_start_auto_spawn()


func _on_closing_time() -> void:
	print("Fermeture — plus de nouveaux clients")
	_auto_spawning = false
	_closing_time_reached = true
	end_of_service_panel.show_panel()
	_check_day_finished()


func _on_customer_exited() -> void:
	active_customer_count -= 1
	_check_day_finished()


func _check_day_finished() -> void:
	if _closing_time_reached and active_customer_count <= 0:
		# TODO étape future : animation de sortie du staff avant d'afficher l'écran
		day_results_screen.setup(level_data, EarningsManager.daily_earnings, daily_goal, expert_goal, EarningsManager.daily_tip)

func _setup_daily_goal() -> void:
	var day_duration: float = day_cycle.service_duration * level_data.active_services.size()

	var result: Dictionary = DailyGoalHelper.compute_daily_goal(
		level_data,
		table_count,
		avg_customer_travel_time,
		avg_customer_speed,
		avg_cleaning_duration,
		sitting_animation_delay,
		payment_queue.bill_display_duration,
		day_duration,
		expert_threshold_percent
	)

	daily_goal = result["daily_goal"]
	expert_goal = result["expert_goal"]
	avg_cycle_duration = result["cycle_duration"]


func _start_auto_spawn() -> void:
	_auto_spawning = true

	var initial_delay: float = randf_range(initial_spawn_delay_min, initial_spawn_delay_max)
	await get_tree().create_timer(initial_delay).timeout

	while _auto_spawning:
		_spawn_next_group()
		var interval: float = _compute_spawn_interval()
		await get_tree().create_timer(interval).timeout


func _compute_spawn_interval() -> float:
	if table_count <= 0 or avg_cycle_duration <= 0.0:
		return 10.0 # valeur de secours si les métriques n'ont pas pu être calculées

	var base_interval: float = avg_cycle_duration / table_count
	var jitter: float = base_interval * (spawn_interval_jitter_percent / 100.0)
	return base_interval + randf_range(-jitter, jitter)


func _spawn_next_group() -> void:
	var all_tables: Array[Node] = get_tree().get_nodes_in_group("Table")
	var valid_sizes: Array[int] = []

	for size: int in range(1, 5):
		if not TableAssignmentService.get_valid_tables(all_tables, size).is_empty():
			valid_sizes.append(size)

	if valid_sizes.is_empty():
		print("Aucune table disponible actuellement, spawn ignoré ce tour-ci")
		return

	var group_size: int = valid_sizes.pick_random()

	if group_size == 1 and randf() * 100.0 < counter_order_probability_percent:
		print("TODO comptoir : groupe de 1 devrait commander au comptoir, envoyé à une table pour l'instant")

	customer_spawner.spawn_entity(group_size)


# TODO : BOUTON TEST. À effacer lorsque les clients entreront aléatoirement dans le restaurant
func _on_spawn_button_pressed() -> void:
	# Appelle ton spawn avec un groupe aléatoire pour tester
	customer_spawner.spawn_entity()
