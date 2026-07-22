extends Node2D
class_name PaymentQueueComponent

@export var queue_positions: Array[Marker2D] = [] # index 0 = à la caisse
@export var exit_marker: Marker2D
@export var interaction_component: Interactable
@export var payment_feedback_label: Label
@export var feedback_display_duration: float = 2.0

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

	_complete_payment(entry["table"], first_customer)
	_advance_queue()


func _complete_payment(table: TableComponent, representative) -> void:
	var bill: float = table.order_component.total_bill
	var tip: float = bill * representative.customer_data.tip_multiplier
	var total_due: float = bill + tip

	_show_payment_feedback(bill, tip, total_due)

	table.occupied_seats.clear()
	table.current_state = GameEnums.TableState.WAITING_FOR_CLEANING if table.is_dirty else GameEnums.TableState.UNOCCUPIED_AND_CLEAN

	var customers: Array[Customer] = table.order_component.seated_customers.duplicate()
	table.order_component.seated_customers.clear()

	for customer: Customer in customers:
		_send_customer_to_exit(customer)


func _show_payment_feedback(bill: float, tip: float, total: float) -> void:
	if not payment_feedback_label:
		return

	payment_feedback_label.text = "%.2f$ (+ %.2f$ tip)" % [bill, tip]
	print("total du paiement : ", total)
	payment_feedback_label.visible = true

	await get_tree().create_timer(feedback_display_duration).timeout
	payment_feedback_label.visible = false
	

func _send_customer_to_exit(customer: Customer) -> void:
	await customer.move_to(exit_marker, GameEnums.CustomerState.MOVING)
	customer.queue_free()


func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		var customer: Customer = _queue[i]["customer"]
		if i < queue_positions.size():
			customer.move_to(queue_positions[i], GameEnums.CustomerState.PAYING)
