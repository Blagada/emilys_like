extends Node2D
class_name CounterOrderComponent

@export var interaction_component: Interactable
@export var payment_queue: PaymentQueueComponent
@export var serving_delay: float = 0.5


func _ready() -> void:
	interaction_component.player_arrived.connect(_on_player_arrived)


func _on_player_arrived(action_id: int) -> void:
	var player: Node = get_tree().get_first_node_in_group("Player")

	if payment_queue.has_servable_counter_customer() and player and player.has_node("StaffComponent"):
		await player.staff_component.start_task(GameEnums.StaffState.DELIVERING, serving_delay)

	payment_queue.serve_next_counter_customer()
	interaction_component.complete_action(action_id)
