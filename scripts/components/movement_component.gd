extends Node
class_name MovementComponent

# Signal utile pour prévenir quand on arrive à destination
signal destination_reached

@export var speed: float = 500.0
@export var nav_agent: NavigationAgent2D
@export var character_body: CharacterBody2D


func _ready() -> void:
	if nav_agent:
		# On connecte le signal natif de Godot au nôtre
		nav_agent.navigation_finished.connect(_on_navigation_finished)


func set_target(target_point: Vector2)-> void:
	if nav_agent:
		nav_agent.target_position = target_point


func get_velocity_for_movement() -> Vector2:
	if not nav_agent or nav_agent.is_navigation_finished():
		return Vector2.ZERO
	
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = character_body.global_position.direction_to(next_path_position)
	
	return direction * speed


func _on_navigation_finished()-> void:
	print("DEBUG: Arrivé !")
	destination_reached.emit()
	
	
func has_arrived() -> bool:
	return not nav_agent or nav_agent.is_navigation_finished()
