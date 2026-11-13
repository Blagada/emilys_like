extends Node
class_name LevelComponent

# --- EXPORTS & CONFIGURATIONS DU NIVEAU ---
@export var restaurant_data: RestaurantData
@export var level_data: LevelData

@export_group("Scripts")
@export var tray_places: TrayComponent
@export var customer_spawner: SpawnComponent
@export var payment_queue: PaymentQueueComponent
@export var day_cycle: DayCycleComponent
@export var order_flow: OrderFlowComponent
@export var spawn_orchestrator: SpawnOrchestratorComponent

@export_group("Scènes")
@export var intersection_panel: IntersectionPanel
@export var level_intro_screen: LevelIntroScreen
@export var restaurant_panel: RestaurantPanel
@export var level_results_screen: LevelResultsScreen
@export var earnings_gauge: EarningsGauge
@export var day_clock: DayClock
@export var level_control: LevelControl
@export var game_menu: GameMenu

@export_group("Nodes")
@export var navigation_region: NavigationRegion2D
@export var spawn_button: Button


# --- MÉTRIQUES ET OBJECTIFS ---
var table_count: int = 0
var total_seats: int = 0
var avg_customer_travel_time: float = 0.0
var avg_customer_speed: float = 0.0
var avg_cleaning_duration: float = 0.0
var avg_cycle_duration: float = 0.0
var daily_goal: float = 0.0
var expert_goal: float = 0.0
var expert_threshold_percent: float = 150.0
var sitting_animation_delay: float = 0.3


# --- INITIALISATION PRINCIPALE ---
func _ready() -> void:
	# --- Injections depuis les Ressources ---
	expert_threshold_percent = level_data.expert_threshold_percent

	spawn_orchestrator.counter_order_probability_percent = level_data.counter_order_probability_percent
	spawn_orchestrator.spawn_interval_jitter_percent = level_data.spawn_interval_jitter_percent
	spawn_orchestrator.initial_spawn_delay_min = level_data.initial_spawn_delay_min
	spawn_orchestrator.initial_spawn_delay_max = level_data.initial_spawn_delay_max
	payment_queue.level_data = level_data

	if restaurant_data:
		sitting_animation_delay = restaurant_data.sitting_animation_delay
		day_cycle.service_duration = restaurant_data.service_duration

	customer_spawner.set_spawn_data(level_data.possible_customers)
	TrayManager.current_max_capacity = level_data.tray_max_capacity
	

	await _setup_level_metrics()
	_setup_daily_goal()

	earnings_gauge.setup(daily_goal, expert_goal)
	level_intro_screen.setup(level_data, table_count, total_seats, daily_goal, expert_goal)
	restaurant_panel.show_restaurant_name(restaurant_data.restaurant_name)

	_connect_tray_pickups()
	level_intro_screen.day_started.connect(_on_day_started)
	day_cycle.closing_time.connect(_on_closing_time)
	day_cycle.day_completed.connect(_on_day_completed)
	game_menu.menu_pressed.connect(_on_menu_pressed)


func _connect_tray_pickups() -> void:
	for food: Node in get_tree().get_nodes_in_group("Food"):
		if food.has_signal("food_clicked"):
			food.food_clicked.connect(tray_places.add_item)


# --- CALCULS DES MÉTRIQUES DE NAVIGATION ---
func _setup_level_metrics() -> void:
	var metrics = await LevelMetricsHelper.compute_metrics(navigation_region, customer_spawner, level_data.possible_customers)
	table_count = metrics["table_count"]
	total_seats = metrics["total_seats"]
	avg_customer_travel_time = metrics["avg_customer_travel_time"]
	avg_customer_speed = metrics["avg_customer_speed"]
	avg_cleaning_duration = metrics["avg_cleaning_duration"]


# --- CONFIGURATION DES OBJECTIFS QUOTIDIENS ---
func _setup_daily_goal() -> void:
	var day_duration: float = day_cycle.service_duration * level_data.active_services.size()

	var result: Dictionary = DailyGoalHelper.compute_daily_goal(
		restaurant_data,
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

	spawn_orchestrator.setup(table_count, avg_cycle_duration)


# --- DÉMARRAGE DE LA JOURNÉE DE TRAVAIL ---
func _on_day_started() -> void:
	EarningsManager.reset_daily()
	day_clock.setup_markers(level_data.active_services.size())
	day_cycle.start_day(level_data.active_services)
	level_control.setup(level_data, restaurant_data, true)
	restaurant_panel.hide_restaurant_name()


# --- HEURE DE FERMETURE ---
func _on_closing_time() -> void:
	intersection_panel.show_timing_panel()


# --- FIN DE JOURNÉE ---
func _on_day_completed() -> void:
	level_results_screen.setup(level_data, EarningsManager.daily_earnings, daily_goal, expert_goal, EarningsManager.daily_tip)
	restaurant_panel.show_restaurant_name(restaurant_data.restaurant_name)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		# Vérifie si le nœud est bien dans l'arbre et complètement prêt avant de mettre à jour
		if is_inside_tree() and not is_queued_for_deletion():
			level_results_screen.texts_setup(level_data, EarningsManager.daily_earnings, daily_goal, expert_goal, EarningsManager.daily_tip)
			level_control.texts_setup(level_data, restaurant_data)
			earnings_gauge.texts_setup(daily_goal, expert_goal)
			restaurant_panel.texts_setup(restaurant_data.restaurant_name)
			
			if is_instance_valid(level_intro_screen):
				level_intro_screen.texts_setup(level_data, table_count, total_seats, daily_goal, expert_goal)


# --- Activation du bouton Menu, pause le jeu + affiche le panneau ---
func _on_menu_pressed(is_open) -> void:
	get_tree().paused = is_open
	if is_open:
		intersection_panel.show_paused_panel()
	else:
		intersection_panel.hide_panel()
		
