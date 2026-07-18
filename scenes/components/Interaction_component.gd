extends Area2D
class_name Interactable

@export var interaction_point: Marker2D

signal player_arrived

func _ready():
	# Si interaction_point n'a pas d'assignation spéacial, assigne le premier enfant de type Marker2D
	if interaction_point == null:
		for child in get_children():
			if child is Marker2D:
				interaction_point = child
				break

func _input_event(_viewport, event, _shape_idx):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var player = get_tree().get_first_node_in_group("Player")
	if player == null or player.is_busy or not player.has_method("set_movement_target"):
		return

	player.is_busy = true
	player.set_movement_target(interaction_point.global_position)
	await player.movement_component.destination_reached

	player.is_busy = false
	player_arrived.emit()
	
