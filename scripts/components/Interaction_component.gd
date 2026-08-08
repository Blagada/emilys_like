extends Area2D
class_name Interactable

@export var interaction_point: Marker2D

signal action_queued(action_id: int)
signal player_arrived(action_id: int)
signal hover_started
signal hover_ended

var _current_action_id: int = -1
var can_interact: Callable = Callable()

func _ready() -> void:
	if interaction_point == null:
		for child: Node in get_children():
			if child is Marker2D:
				interaction_point = child
				break
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var player: Node = get_tree().get_first_node_in_group("Player")
	if player == null or not player.has_node("ActionQueueComponent"):
		return
		
	if can_interact.is_valid() and not can_interact.call():
		return

	_current_action_id = player.action_queue.enqueue(interaction_point, _on_action_execute)
	action_queued.emit(_current_action_id)


func _on_action_execute(action_id: int) -> void:
	# _current_action_id = action_id
	player_arrived.emit(action_id)


func complete_action(action_id: int) -> void:
	var player: Node = get_tree().get_first_node_in_group("Player")
	if player:
		player.action_queue.complete_current(action_id)


# ---- Hover
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover_started.emit()


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover_ended.emit()
# ---
