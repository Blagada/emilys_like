extends Node2D
class_name PaymentQueueComponent

# --- EXPORTS & CONFIGURATIONS ---
# Positions successives dans la file d'attente (index 0 = tout devant, directement à la caisse)
@export var queue_positions: Array[Marker2D] = [] 
@export var exit_marker: Marker2D # Point de sortie vers lequel les clients se dirigent après le paiement
@export var interaction_component: Interactable # Composant gérant l'interaction du joueur avec la caisse
@export var payment_feedback_label: Label # Label affichant le montant payé et le pourboire

@export var feedback_display_duration: float = 3.0 # Durée d'affichage du feedback à l'écran
@export var combo_bonus_per_extra_table: float = 0.10 # +10% par client supplémentaire payé dans la même vague
@export var max_combo_bonus_percent: float = 0.50 # plafond à 50%
@export var bill_display_duration: float = 0.5 # temps d'affichage du montant avant que le client parte

# --- VARIABLES INTERNES ---
# File d'attente stockant les clients en attente de paiement et leur table associée
var _queue: Array[Dictionary] = [] # {customer: Customer, table: TableComponent}


# --- INITIALISATION ---
func _ready() -> void:
	# Connecte le signal d'arrivée du joueur sur la caisse
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)


# --- GESTION DE LA FILE (ENQUEUE) ---
# Ajoute un client dans la file d'attente et le fait se déplacer vers sa position assignée
func enqueue(customer: Customer, table: TableComponent) -> void:
	var queue_index: int = _queue.size()
	_queue.append({"customer": customer, "table": table})

	# Si une position de file est disponible pour ce client, on l'y fait avancer
	if queue_index < queue_positions.size():
		customer.move_to(queue_positions[queue_index], GameEnums.CustomerState.PAYING)


# --- INTERACTION DU JOUEUR (CAISSE) ---
# Déclenché lorsque le joueur interagit avec la caisse pour encaisser le premier client
func _on_player_arrived(action_id: int) -> void:
	if _queue.is_empty():
		interaction_component.complete_action(action_id)
		return

	await _process_queue_sequentially()
	interaction_component.complete_action(action_id)


func _process_queue_sequentially() -> void:
	# 1. Inventaire figé : qui est déjà arrivé à sa position, AVANT de déplacer qui que ce soit
	var to_process: Array[Dictionary] = []
	for entry: Dictionary in _queue:
		var customer: Customer = entry["customer"]
		if customer.movement_component.has_arrived():
			to_process.append(entry)

	if to_process.is_empty():
		return

	for entry: Dictionary in to_process:
		_queue.erase(entry)

	# 2. Traitement séquentiel de cette liste figée
	var total_bill_batch: float = 0.0
	var total_tip_batch: float = 0.0
	var total_combo_bonus: float = 0.0
	var combo_index: int = 0

	for entry: Dictionary in to_process:
		var customer: Customer = entry["customer"]
		var table: TableComponent = entry["table"]

		await customer.move_to(queue_positions[0], GameEnums.CustomerState.PAYING)

		var bill: float = table.order_component.total_bill
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

		table.occupied_seats.clear()
		table.current_state = GameEnums.TableState.WAITING_FOR_CLEANING if table.is_dirty else GameEnums.TableState.UNOCCUPIED_AND_CLEAN

		var seated_customers: Array[Customer] = table.order_component.seated_customers.duplicate()
		seated_customers.erase(customer) # le représentant part séparément, après son délai d'affichage
		table.order_component.seated_customers.clear()

		for seated_customer: Customer in seated_customers:
			_send_customer_to_exit(seated_customer)

		_send_customer_to_exit(customer)

	# 3. Une seule fois à la fin : on fait avancer ceux qui restent
	_advance_queue()

	EarningManager.add_earnings(total_bill_batch, total_tip_batch)
	_show_payment_feedback(total_bill_batch, total_tip_batch, total_combo_bonus)

# --- ANIMATION DU FEEDBACK DE PAIEMENT ---
func _show_payment_feedback(bill: float, tip: float, combo_bonus: float) -> void:
	if not payment_feedback_label:
		return

	# Construction du texte de base
	var feedback_text: String = "%.2f$ (+ %.2f$ tip)" % [bill, tip]
	
	# Si on a un bonus de tables multiples, on ajoute la ligne Combo
	if combo_bonus > 0.0:
		feedback_text += " + combo : %.2f$" % [combo_bonus]
		print("feedback_text : ", feedback_text)

	# Configure le texte du montant et initialise l'animation (échelle à 0, transparent)
	payment_feedback_label.text = feedback_text
	payment_feedback_label.pivot_offset = payment_feedback_label.size / 2
	payment_feedback_label.modulate.a = 0.0
	payment_feedback_label.scale = Vector2.ZERO
	payment_feedback_label.visible = true

	# Animation d'apparition avec effet de rebond (Tween)
	var tween: Tween = create_tween()
	tween.tween_property(payment_feedback_label, "scale", Vector2(1.1, 1.1), 0.15)
	tween.parallel().tween_property(payment_feedback_label, "modulate:a", 1.0, 0.15)
	tween.tween_property(payment_feedback_label, "scale", Vector2.ONE, 0.1)

	# Attend la fin de la durée d'affichage configurée
	await get_tree().create_timer(feedback_display_duration).timeout

	# Animation de disparition en fondu (Fade out)
	var fade_out: Tween = create_tween()
	fade_out.tween_property(payment_feedback_label, "modulate:a", 0.0, 0.3)
	await fade_out.finished

	payment_feedback_label.visible = false
	

# --- SORTIE DU CLIENT ---
# Fait marcher le client vers la sortie du restaurant puis supprime son instance de la mémoire
func _send_customer_to_exit(customer: Customer) -> void:
	await customer.move_to(exit_marker, GameEnums.CustomerState.MOVING)
	customer.queue_free()


# --- MISE À JOUR DE LA FILE D'ATTENTE ---
# Fait avancer d'un cran tous les clients restants dans la file vers la caisse
func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		var customer: Customer = _queue[i]["customer"]
		if i < queue_positions.size():
			customer.move_to(queue_positions[i], GameEnums.CustomerState.PAYING)
