extends Node
class_name DayCycleComponent

@export var payment_queue: PaymentQueueComponent
@export var service_duration: float = 240.0 # 4 minutes, fixe peu importe le niveau

signal service_started(service_type: GameEnums.ServiceType)
signal closing_time
signal day_completed

var active_services: Array[GameEnums.ServiceType] = []
var total_day_duration: float = 0.0
var elapsed_time: float = 0.0
var active_customer_count: int = 0

var _is_running: bool = false
var _closing_time_reached: bool = false
var _day_completed_emitted: bool = false


func _ready() -> void:
	if payment_queue:
		payment_queue.customer_exited.connect(_on_customer_exited)


func start_day(services: Array[GameEnums.ServiceType]) -> void:
	active_services = services
	total_day_duration = service_duration * services.size()
	elapsed_time = 0.0
	_is_running = true
	_run_services()


func register_customer_spawned() -> void:
	active_customer_count += 1


func _process(delta: float) -> void:
	if _is_running:
		elapsed_time += delta


func _run_services() -> void:
	for service: GameEnums.ServiceType in active_services:
		service_started.emit(service)
		await get_tree().create_timer(service_duration).timeout

	closing_time.emit()
	_is_running = false
	_closing_time_reached = true
	_check_day_finished()


func _on_customer_exited() -> void:
	active_customer_count -= 1
	_check_day_finished()


func _check_day_finished() -> void:
	if _day_completed_emitted:
		return

	if _closing_time_reached and active_customer_count <= 0:
		_day_completed_emitted = true
		day_completed.emit()
