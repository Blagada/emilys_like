extends Area2D
class_name Interactable

signal interaction_ready # Signal qui annonce que le déplacement est terminé

@export var interaction_point: Marker2D

func _ready():
	# Si interaction_point n'a pas d'assignation spéacial, assigne le premier enfant de type Marker2D
	if interaction_point == null:
		for child in get_children():
			if child is Marker2D:
				interaction_point = child
				break

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_first_node_in_group("Player")
		
		if player != null and player.has_method("set_movement_target"):
			player.set_movement_target(interaction_point.global_position)
			
			# On attend ici que le mouvement soit terminé grâce au signal
			await player.movement_component.destination_reached
			
			print("DEBUG: Arrivé !")
			interaction_ready.emit()
