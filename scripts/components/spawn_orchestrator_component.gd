extends Node
class_name SpawnOrchestratorComponent

@export var customer_spawner: SpawnComponent
@export var payment_queue: PaymentQueueComponent
@export var day_cycle: DayCycleComponent

@export var counter_order_probability_percent: float = 70.0
@export var spawn_interval_jitter_percent: float = 20.0
@export var initial_spawn_delay_min: float = 1.0
@export var initial_spawn_delay_max: float = 2.0

@onready var level_manager: LevelComponent = get_tree().get_first_node_in_group("LevelManager")

var table_count: int = 0
var avg_cycle_duration: float = 0.0

var _auto_spawning: bool = false


func _ready() -> void:
	day_cycle.service_started.connect(_on_service_started)
	day_cycle.closing_time.connect(_on_closing_time)


func setup(new_table_count: int, new_avg_cycle_duration: float) -> void:
	table_count = new_table_count
	avg_cycle_duration = new_avg_cycle_duration


func _on_service_started(_service: GameEnums.ServiceType) -> void:
	if not _auto_spawning:
		_start_auto_spawn()


func _on_closing_time() -> void:
	_auto_spawning = false


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
		return 10.0

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
		_spawn_counter_customer()
		return

	customer_spawner.spawn_entity(group_size)


func _spawn_counter_customer() -> void:
	var customer: Customer = customer_spawner.spawn_single_customer()
	if customer == null:
		return

	day_cycle.register_customer_spawned()
	payment_queue.enqueue_counter_customer(customer, level_manager.level_data.level_menu)
