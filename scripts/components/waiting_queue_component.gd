extends Node2D
class_name WaitingQueueComponent

@export var order_flow: OrderFlowComponent
@export var queue_positions: Array[Marker2D] = []
@export var exit_marker: Marker2D
@export var day_cycle: DayCycleComponent

# {"customer": représentant, "group": Array[Customer]}
var _queue: Array[Dictionary] = []


func _ready() -> void:
	for table_node: Node in get_tree().get_nodes_in_group("Table"):
		var table_comp: TableComponent = table_node.get_node_or_null("TableComponent")
		if table_comp:
			table_comp.table_freed.connect(_on_table_freed.bind(table_comp))

	day_cycle.closing_time.connect(_on_closing_time)

# --- AJOUTE UN GROUPE SANS TABLE DISPONIBLE DANS LA FILE ---
func enqueue_group(group: Array[Customer]) -> void:
	var representative: Customer = group[0]
	var queue_index: int = _queue.size()
	_queue.append({"customer": representative, "group": group})

	if queue_index < queue_positions.size():
		representative.move_to(queue_positions[queue_index])

	representative.show_group_size(group.size())

	representative.patience_component.start(representative.customer_data.patience)
	representative.patience_component.patience_expired.connect(
		_on_queue_patience_expired.bind(group)
	)


func has_capacity() -> bool:
	return _queue.size() < queue_positions.size()


# --- UNE TABLE VIENT DE SE LIBÉRER : ON CHERCHE LE MEILLEUR GROUPE EN ATTENTE ---
func _on_table_freed(table: TableComponent) -> void:
	var best_index: int = -1
	var best_size: int = -1

	for i: int in range(_queue.size()):
		var group: Array[Customer] = _queue[i]["group"]
		if table.can_accommodate_group(group.size()) and group.size() > best_size:
			best_index = i
			best_size = group.size()

	if best_index == -1:
		return

	var entry: Dictionary = _queue[best_index]
	_queue.remove_at(best_index)
	_assign_group_to_table(entry, table)
	_advance_queue()


# --- RETIRE LE GROUPE DE LA FILE ET LE CONFIE À L'ASSISE ---
func _assign_group_to_table(entry: Dictionary, table: TableComponent) -> void:
	var representative: Customer = entry["customer"]
	_detach_patience(representative)
	order_flow.seat_group(table, entry["group"])


# --- PATIENCE EXPIRÉE EN FILE : TOUT LE GROUPE QUITTE (JAMAIS ASSIS) ---
func _on_queue_patience_expired(group: Array[Customer]) -> void:
	_remove_group_from_queue(group)
	for customer: Customer in group:
		CustomerExitService.send_customer_to_exit(customer, exit_marker)
	_advance_queue()


func _remove_group_from_queue(group: Array[Customer]) -> void:
	for i: int in range(_queue.size()):
		if _queue[i]["group"] == group:
			_queue.remove_at(i)
			return


# --- FAIT AVANCER LES REPRÉSENTANTS RESTANTS D'UNE POSITION ---
func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		if i < queue_positions.size():
			_queue[i]["customer"].move_to(queue_positions[i])


func _detach_patience(representative: Customer) -> void:
	representative.patience_component.cancel()
	for connection: Dictionary in representative.patience_component.patience_expired.get_connections():
		representative.patience_component.patience_expired.disconnect(connection["callable"])
	representative.hide_bubble()
	

# --- LE RESTO FERME : PLUS PERSONNE NE PEUT ENTRER, TOUTE LA FILE S'EN VA ---
func _on_closing_time() -> void:
	for entry: Dictionary in _queue:
		_detach_patience(entry["customer"])

		for customer: Customer in entry["group"]:
			CustomerExitService.send_customer_to_exit(customer, exit_marker)

	_queue.clear()
