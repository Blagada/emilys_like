extends Node
class_name DayCycleComponent

signal service_started(service_type: GameEnums.ServiceType)
signal closing_time
signal day_completed

@export var service_duration: float = 240.0 # 4 minutes, fixe peu importe le niveau

var active_services: Array[GameEnums.ServiceType] = []


func start_day(services: Array[GameEnums.ServiceType]) -> void:
	active_services = services
	_run_services()


func _run_services() -> void:
	for service: GameEnums.ServiceType in active_services:
		service_started.emit(service)
		await get_tree().create_timer(service_duration).timeout

	closing_time.emit()

	# TODO étape 6 : attendre que le compteur de clients actifs retombe à 0
	# + l'animation de sortie du staff, avant d'émettre day_completed pour de vrai
	day_completed.emit()
