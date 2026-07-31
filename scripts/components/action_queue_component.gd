extends Node
class_name ActionQueueComponent

signal action_started(action_id: int)
signal action_completed(action_id: int)
signal action_cancelled(action_id: int)

@onready var player: Player = get_parent() as Player

class QueuedAction:
	var id: int
	var target_marker: Marker2D
	var on_execute: Callable
	var cancelled: bool = false
	var started: bool = false

var _queue: Array[QueuedAction] = []
var _current_action: QueuedAction = null
var _next_id: int = 0
var _is_processing: bool = false


func enqueue(target_marker: Marker2D, on_execute: Callable) -> int:
	var action: QueuedAction = QueuedAction.new()
	action.id = _next_id
	_next_id += 1
	action.target_marker = target_marker
	action.on_execute = on_execute
	_queue.append(action)

	if not _is_processing:
		_process_next()

	return action.id


func cancel(action_id: int) -> bool:
	for i: int in range(_queue.size()):
		if _queue[i].id == action_id:
			_queue.remove_at(i)
			action_cancelled.emit(action_id)
			return true

	# Encore en déplacement (pas commencé) : on peut annuler
	if _current_action and _current_action.id == action_id and not _current_action.started:
		_current_action.cancelled = true
		action_cancelled.emit(action_id)
		return true

	return false # déjà en cours d'exécution, trop tard


func complete_current(action_id: int) -> void:
	if _current_action and _current_action.id == action_id:
		action_completed.emit(action_id)
		_current_action = null
		_is_processing = false
		_process_next()


func _process_next() -> void:
	if _queue.is_empty():
		return

	_is_processing = true
	_current_action = _queue.pop_front()
	
	var target: Vector2 = _current_action.target_marker.global_position
	# Valide la position du joueur et la distance avec le target +- 5
	var already_there: bool = player.global_position.distance_to(target) < 5.0

	player.set_movement_target(target)
	
	# Valide s'il y a un trajet à faire avant de déplacer le joueur
	if not already_there:
		# Attend que le joueur atteingne la destination de la prochaine action
		await player.movement_component.destination_reached

	# Le joueur vient d'arriver : vérifie si l'action a été annulée pendant le trajet
	if _current_action == null or _current_action.cancelled:
		_is_processing = false
		_process_next()
		return

	_current_action.started = true
	action_started.emit(_current_action.id)
	_current_action.on_execute.call(_current_action.id)
