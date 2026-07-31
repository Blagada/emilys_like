extends Node
class_name DayCycleComponent

signal service_started(service_type: GameEnums.ServiceType)
signal closing_time

@export var service_duration: float = 240.0 # 4 minutes, fixe peu importe le niveau

var active_services: Array[GameEnums.ServiceType] = []
var total_day_duration: float = 0.0
var elapsed_time: float = 0.0
var _is_running: bool = false


func _process(delta: float) -> void:
	if _is_running:
		elapsed_time += delta


func start_day(services: Array[GameEnums.ServiceType]) -> void:
	active_services = services
	total_day_duration = service_duration * services.size()
	elapsed_time = 0.0
	_is_running = true
	_run_services()


func _run_services() -> void:
	for service: GameEnums.ServiceType in active_services:
		service_started.emit(service)
		await get_tree().create_timer(service_duration).timeout

	closing_time.emit()
	_is_running = false
