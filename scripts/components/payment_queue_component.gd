extends Node2D
class_name PaymentQueueComponent

signal customer_exited

# --- EXPORTS & CONFIGURATIONS ---
@export var queue_positions: Array[Marker2D] = []
@export var exit_marker: Marker2D
@export var interaction_component: Interactable
@export var payment_feedback_label: Label

@export var feedback_display_duration: float = 3.0
@export var combo_bonus_per_extra_table: float = 0.10
@export var max_combo_bonus_percent: float = 0.50
@export var bill_display_duration: float = 0.5

# --- VARIABLES INTERNES ---
# {customer, table (null si comptoir), order_price (utilisé seulement si table == null), is_served}
var _queue: Array[Dictionary] = []


func _ready() -> void:
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)
		interaction_component.action_queued.connect(_on_action_queued)


# --- GESTION DE LA FILE (ENQUEUE) — clients de table, déjà servis ---
func enqueue(customer: Customer, table: TableComponent) -> void:
	var queue_index: int = _queue.size()
	_queue.append({"customer": customer, "table": table, "order_price": 0.0, "is_served": true})

	customer.show_waiting_payment_bubble()
	# Patience du client activé
	var current_patience_state = customer.patience_component.get_current_state()
	
	for connection: Dictionary in customer.patience_component.patience_expired.get_connections():
		customer.patience_component.patience_expired.disconnect(connection["callable"])
	
	customer.patience_component.start(customer.customer_data.patience, current_patience_state)
	customer.patience_component.patience_expired.connect(
		_on_queue_patience_expired.bind(customer, table)
	)

	if queue_index < queue_positions.size():
		customer.move_to(queue_positions[queue_index], GameEnums.CustomerState.PAYING)


# --- GESTION DE LA FILE (ENQUEUE) — clients de comptoir, pas encore servis ---
func enqueue_counter_customer(customer: Customer, level_menu: LevelMenu) -> void:
	var entry: Dictionary = {"customer": customer, "table": null, "order_price": 0.0, "is_served": false}
	var queue_index: int = _queue.size()
	_queue.append(entry)
	
	# attend que le client arrive au comptoir
	if queue_index < queue_positions.size():
		await customer.move_to(queue_positions[queue_index])

	# affiche la bulle "..." sur ce client.
	customer.change_state(GameEnums.CustomerState.WAITING_TO_ORDER)
	customer.show_thinking()

	# attendre un court délai avant de révéler la commande.
	# la durée concorde avec la vitesse du client 400 / 100 = 4 secondes (le client à une vitesse sur 100)
	var thinking_delay: float = 400.0 / customer.customer_data.speed
	await get_tree().create_timer(thinking_delay).timeout

	# choisi un aliment aléatoire à partir de level_menu.
	var food: FoodData = level_menu.get_random_food()

	# assigne cet aliment au client + mettre à jour entry["order_price"] avec son prix.
	customer.set_order(food)
	entry["order_price"] = food.price

	# affiche la bulle avec l'icône de l'aliment choisi + changement d'état.
	customer.change_state(GameEnums.CustomerState.ORDERING)
	customer.show_order_bubble(food)
	# Patience du client activé
	customer.patience_component.start(customer.customer_data.patience)
	customer.patience_component.patience_expired.connect(
		_on_queue_patience_expired.bind(customer, null)
	)


# --- SERVICE AU COMPTOIR (cloche) ---
func has_servable_counter_customer() -> bool:
	for entry: Dictionary in _queue:
		if entry["table"] == null and not entry["is_served"] and TrayManager.tray_items.has(entry["customer"].current_order):
			return true
	return false


func serve_next_counter_customer() -> void:
	for entry: Dictionary in _queue:
		if entry["table"] == null and not entry["is_served"] and TrayManager.tray_items.has(entry["customer"].current_order):
			TrayManager.tray_items.erase(entry["customer"].current_order)
			TrayManager.tray_updated.emit()
			entry["is_served"] = true
			entry["customer"].show_waiting_payment_bubble()
			return


# --- INTERACTION DU JOUEUR (CAISSE) ---
func _on_player_arrived(action_id: int) -> void:
	if _queue.is_empty():
		interaction_component.complete_action(action_id)
		return

	await _process_queue_sequentially()
	interaction_component.complete_action(action_id)


func _process_queue_sequentially() -> void:
	var total_bill_batch: float = 0.0
	var total_tip_batch: float = 0.0
	var total_combo_bonus: float = 0.0
	var combo_index: int = 0

	# On traite la file tant qu'il y a des clients prêts au début
	while not _queue.is_empty():
		var first_entry: Dictionary = _queue[0]
		var customer: Customer = first_entry["customer"]
		
		# Si le premier client n'est pas prêt, on arrête le traitement du lot ici
		if not (first_entry["is_served"] and customer.movement_component.has_arrived()):
			break

		# 1. On le retire de la file principale au moment où il commence son encaissement
		_queue.pop_front()
		# Pris en charge, arrête le timer de patience
		customer.patience_component.cancel()

		var table: TableComponent = first_entry["table"]

		# Le client se déplace vers la caisse (position 0)
		await customer.move_to(queue_positions[0], GameEnums.CustomerState.PAYING)

		var bill: float = table.order_component.total_bill if table != null else first_entry["order_price"]
		var tip: float = bill * customer.customer_data.tip_rate

		var combo_percent: float = min(combo_bonus_per_extra_table * combo_index, max_combo_bonus_percent)
		var combo_bonus: float = bill * combo_percent
		bill += combo_bonus
		combo_index += 1

		customer.show_bill_amount(bill)
		await get_tree().create_timer(bill_display_duration).timeout

		total_bill_batch += bill
		total_tip_batch += tip
		total_combo_bonus += combo_bonus

		if table != null:
			var seated_customers: Array[Customer] = table.order_component.seated_customers.duplicate()
			seated_customers.erase(customer)

			CustomerExitService.release_table(table)

			for seated_customer: Customer in seated_customers:
				_send_customer_to_exit(seated_customer)

		# 3. Le client quitte la caisse et sort
		# Le client précédent commence tout juste à sortir — les suivants peuvent avancer maintenant
		_advance_queue()
		_send_customer_to_exit(customer)
		
		# Le client précédent vient de partir, on laisse passer un petit délai 
		# avant que le prochain de la file ne s'élance vers la caisse libérée.
		# TODO : si possible que le délai n'impacte que les clients dans la fil (pas celui à la caisse)
		await get_tree().create_timer(0.9).timeout
		_advance_queue()

	if total_bill_batch > 0.0:
		EarningsManager.add_earnings(total_bill_batch, total_tip_batch)
		_show_payment_feedback(total_bill_batch, total_tip_batch, total_combo_bonus)


# --- ANIMATION DU FEEDBACK DE PAIEMENT ---
func _show_payment_feedback(bill: float, tip: float, combo_bonus: float) -> void:
	if not payment_feedback_label:
		return

	var feedback_text: String = "%.2f$ (+ %.2f$ tip)" % [bill, tip]

	if combo_bonus > 0.0:
		feedback_text += " + combo : %.2f$" % [combo_bonus]

	payment_feedback_label.text = feedback_text
	payment_feedback_label.pivot_offset = payment_feedback_label.size / 2
	payment_feedback_label.modulate.a = 0.0
	payment_feedback_label.scale = Vector2.ZERO
	payment_feedback_label.visible = true

	var tween: Tween = create_tween()
	tween.tween_property(payment_feedback_label, "scale", Vector2(1.1, 1.1), 0.15)
	tween.parallel().tween_property(payment_feedback_label, "modulate:a", 1.0, 0.15)
	tween.tween_property(payment_feedback_label, "scale", Vector2.ONE, 0.1)

	await get_tree().create_timer(feedback_display_duration).timeout

	var fade_out: Tween = create_tween()
	fade_out.tween_property(payment_feedback_label, "modulate:a", 0.0, 0.3)
	await fade_out.finished

	payment_feedback_label.visible = false


func _on_queue_patience_expired(customer: Customer, table: TableComponent) -> void:
	_remove_customer_from_queue(customer)

	if table != null:
		var group: Array[Customer] = table.order_component.seated_customers.duplicate()
		for member: Customer in group:
			member.patience_component.cancel()
		CustomerExitService.release_table(table)
		for member: Customer in group:
			_send_customer_to_exit(member)
	else:
		_send_customer_to_exit(customer)

	_advance_queue()


func _remove_customer_from_queue(customer: Customer) -> void:
	for i: int in range(_queue.size()):
		if _queue[i]["customer"] == customer:
			_queue.remove_at(i)
			return


# --- SORTIE DU CLIENT ---
func _send_customer_to_exit(customer: Customer) -> void:
	CustomerExitService.send_customer_to_exit(
		customer, exit_marker,
		func() -> void: customer_exited.emit()
	)


# --- MISE À JOUR DE LA FILE D'ATTENTE ---
func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		var entry: Dictionary = _queue[i]
		var customer: Customer = entry["customer"]
		
		if not is_instance_valid(customer):
			continue # Ignore ce client, il n'existe plus en mémoire
		
		if i < queue_positions.size():
			var state: GameEnums.CustomerState = GameEnums.CustomerState.PAYING if entry["is_served"] else GameEnums.CustomerState.MOVING
			customer.move_to(queue_positions[i], state)


# Pause la patience lorsque le queue est actif
func _on_action_queued(_action_id: int) -> void:
	for entry: Dictionary in _queue:
		entry["customer"].patience_component.cancel()
