extends Node2D
class_name CounterOrderComponent

@export_group("Scripts")
@export var counter_order_interaction: Interactable
@export var payment_queue: PaymentQueueComponent
@export var data: CounterData = CounterData.new()

func _ready() -> void:
	counter_order_interaction.player_arrived.connect(_on_player_arrived)


func _on_player_arrived(action_id: int) -> void:
	var player: Node = get_tree().get_first_node_in_group("Player")

	if payment_queue.has_servable_counter_customer() and player and player.has_node("StaffComponent"):
		await player.staff_component.start_task(GameEnums.StaffState.DELIVERING, data.serving_delay)

	payment_queue.serve_next_counter_customer()
	counter_order_interaction.complete_action(action_id)
