extends Node2D
class_name PaymentQueueComponent

@export var queue_positions: Array[Marker2D] = [] # index 0 = à la caisse
@export var exit_marker: Marker2D
@export var interaction_component: Interactable

var _queue: Array[Dictionary] = [] # {customer: Customer, table: TableComponent}


func _ready() -> void:
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)


func enqueue(customer: Customer, table: TableComponent) -> void:
	var queue_index: int = _queue.size()
	_queue.append({"customer": customer, "table": table})

	if queue_index < queue_positions.size():
		customer.move_to(queue_positions[queue_index], GameEnums.CustomerState.PAYING)
	


func _on_player_arrived() -> void:
	if _queue.is_empty():
		return

	var first_customer: Customer = _queue[0]["customer"]
	if not first_customer.movement_component.has_arrived():
		return

	var entry: Dictionary = _queue[0]
	_queue.remove_at(0)

	_complete_payment(entry["table"])
	_advance_queue()


func _complete_payment(table: TableComponent) -> void:
	table.order_component.hide_order_bubble()
	table.current_state = GameEnums.TableState.UNOCCUPIED_AND_DIRTY

	var customers: Array[Customer] = table.order_component.seated_customers.duplicate()
	table.order_component.seated_customers.clear()

	for customer: Customer in customers:
		_send_customer_to_exit(customer)


func _send_customer_to_exit(customer: Customer) -> void:
	await customer.move_to(exit_marker, GameEnums.CustomerState.MOVING)
	customer.queue_free()


func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		var customer: Customer = _queue[i]["customer"]
		if i < queue_positions.size():
			customer.move_to(queue_positions[i], GameEnums.CustomerState.PAYING)
