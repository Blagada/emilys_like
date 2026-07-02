extends Node
class_name MovementComponent

# Signal utile pour prévenir quand on arrive à destination
signal destination_reached

@export var speed: float = 500.0
@export var nav_agent: NavigationAgent2D
@export var character_body: CharacterBody2D

func _ready():
	# On connecte le signal natif de Godot au nôtre
	nav_agent.navigation_finished.connect(_on_navigation_finished)

func set_target(target_point: Vector2):
	nav_agent.target_position = target_point

func get_velocity_for_movement() -> Vector2:
	if nav_agent.is_navigation_finished():
		return Vector2.ZERO
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = character_body.global_position.direction_to(next_path_position)
	return direction * speed

func _on_navigation_finished():
	print("DEBUG: Arrivé !")
	destination_reached.emit()
