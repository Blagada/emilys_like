extends Node2D
class_name PaymentQueueComponent

# Signal émis chaque fois qu'un client termine complètement sa sortie de la scène
signal customer_exited

# --- EXPORTS & CONFIGURATIONS ---
@export_group("Composants & Dépendances")
@export var interaction_component: Interactable
@export var feedback_display: PaymentFeedbackDisplay
@export var counter_order_flow: CounterOrderFlowComponent
@export var exit_marker: Marker2D

@export_group("Paramètres de la File & Économie")
@export var queue_positions: Array[Marker2D] = [] # Positions physiques de la file d'attente à la caisse
@export var bill_display_duration: float = 0.5 # Temps d'affichage du montant au-dessus du client

# --- VARIABLES INTERNES ---
var level_data: LevelData # Fourni par LevelManager

# File d'attente sous forme de dictionnaires :
# Structuré ainsi : { customer: Customer, table: TableComponent (null si comptoir), order_price: float, is_served: bool }
var _queue: Array[Dictionary] = []


func _ready() -> void:
	# Connexion des événements du composant d'interaction de la caisse
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)
		interaction_component.action_queued.connect(_on_action_queued)


# ==============================================================================
# --- GESTION DE LA FILE D'ATTENTE (ENQUEUE) ---
# ==============================================================================

## Ajoute à la file un représentant de groupe venu d'une TABLE (client déjà servi).
func enqueue(customer: Customer, table: TableComponent) -> void:
	var queue_index: int = _queue.size()
	_queue.append({"customer": customer, "table": table, "order_price": 0.0, "is_served": true})

	# Affichage de la bulle d'attente de paiement ($)
	customer.show_waiting_payment_bubble()
	
	# Gestion de la patience : on conserve l'état actuel (HAPPY/IMPATIENT) et on réinitialise les connexions
	var current_patience_state = customer.patience_component.get_current_state()
	
	# Nettoyage des anciennes connexions sur l'expiration pour éviter les doublons de callbacks
	for connection: Dictionary in customer.patience_component.patience_expired.get_connections():
		customer.patience_component.patience_expired.disconnect(connection["callable"])
	
	# Démarrage du timer de patience en file et branchement du cas d'expiration
	customer.patience_component.start(customer.customer_data.patience, current_patience_state)
	customer.patience_component.patience_expired.connect(
		on_queue_patience_expired.bind(customer, table)
	)

	# Déplacement du client vers son emplacement dans la file
	if queue_index < queue_positions.size():
		customer.move_to(queue_positions[queue_index], GameEnums.CustomerState.PAYING)


## Ajoute à la file un client venu commander au COMPTOIR (pas encore servi).
func enqueue_counter_customer(customer: Customer, level_menu: LevelMenu) -> void:
	var entry: Dictionary = {"customer": customer, "table": null, "order_price": 0.0, "is_served": false}
	var queue_index: int = _queue.size()
	_queue.append(entry)
	
	# Attend que le client soit physiquement arrivé à sa place dans la file
	if queue_index < queue_positions.size():
		await customer.move_to(queue_positions[queue_index])

	# Déclenche la prise de commande spécifique au comptoir
	counter_order_flow.take_order(customer, level_menu, entry)


# ==============================================================================
# --- SERVICE AU COMPTOIR (CLOCHE) ---
# ==============================================================================

## Vérifie si au moins un client du comptoir a sa commande prête sur le plateau du joueur.
func has_servable_counter_customer() -> bool:
	for entry: Dictionary in _queue:
		if entry["table"] == null and not entry["is_served"] and TrayManager.tray_items.has(entry["customer"].current_order):
			return true
	return false


## Sert le premier client de comptoir dont la commande est dans le plateau.
func serve_next_counter_customer() -> void:
	for entry: Dictionary in _queue:
		if entry["table"] == null and not entry["is_served"] and TrayManager.tray_items.has(entry["customer"].current_order):
			# Retire le plat du plateau et met à jour l'état du client
			TrayManager.tray_items.erase(entry["customer"].current_order)
			TrayManager.tray_updated.emit()
			entry["is_served"] = true
			entry["customer"].show_waiting_payment_bubble()
			return


# ==============================================================================
# --- TRAITEMENT DES ENCAISSEMENTS (INTERACTION CAISSE) ---
# ==============================================================================

## Déclenché lorsque le joueur arrive physiquement devant la caisse.
func _on_player_arrived(action_id: int) -> void:
	if _queue.is_empty():
		interaction_component.complete_action(action_id)
		return

	# Traite tous les clients prêts dans la file à la suite
	await _process_queue_sequentially()
	interaction_component.complete_action(action_id)


## Boucle d'encaissement séquentielle qui calcule les montants, pourboires et combos.
func _process_queue_sequentially() -> void:
	var total_bill_batch: float = 0.0
	var total_tip_batch: float = 0.0
	var total_combo_bonus: float = 0.0
	var combo_index: int = 0 # Compteur pour le multiplicateur de combo lors d'encaissements multiples

	# On traite la file tant qu'il y a des clients prêts au début de celle-ci
	while not _queue.is_empty():
		var first_entry: Dictionary = _queue[0]
		var customer: Customer = first_entry["customer"]
		
		# Garde : si le premier client n'est pas encore servi ou n'est pas arrivé, on stoppe le lot
		if not (first_entry["is_served"] and customer.movement_component.has_arrived()):
			break

		# 1. On retire le client de la file et on stoppe son décompte de patience
		_queue.pop_front()
		customer.patience_component.cancel()

		var table: TableComponent = first_entry["table"]

		# Avance le client directement au poste de paiement (index 0)
		await customer.move_to(queue_positions[0], GameEnums.CustomerState.PAYING)

		# 2. Calculs de la transaction via BillingService
		var base_price: float = table.order_component.total_bill if table != null else first_entry["order_price"]
		var patience_state: GameEnums.PatienceState = customer.patience_component.get_current_state()

		var is_single_trip: bool = true
		if table != null:
			is_single_trip = table.order_component.is_single_trip_service()

		var transaction: Dictionary = BillingService.compute_transaction(
			base_price, customer.customer_data.tip_rate, patience_state, 
			combo_index, level_data.combo_bonus_rate_per_table, level_data.max_combo_bonus_rate,
			is_single_trip, level_data.single_trip_bonus_rate
		)
		
		var bill: float = transaction["bill"]
		var tip: float = transaction["tip"]
		var combo_bonus: float = transaction["combo_bonus"]
		var single_trip_bonus: float = transaction["single_trip_bonus"]
		combo_index += 1 # Augmente le niveau de combo pour le client suivant du même lot
		if combo_bonus > 0.0 or single_trip_bonus > 0.0:
			customer.show_bonus_star()

		# Feedback du montant au-dessus du client
		customer.show_bill_amount(bill)
		await get_tree().create_timer(bill_display_duration, false).timeout

		# Accumulation des totaux de cette session d'encaissement
		total_bill_batch += bill
		total_tip_batch += tip
		total_combo_bonus += combo_bonus

		# Si c'était un groupe à table, libère la table et fait sortir les autres membres assis
		if table != null:
			var seated_customers: Array[Customer] = table.order_component.seated_customers.duplicate()
			seated_customers.erase(customer)

			CustomerExitService.release_table(table)

			for seated_customer: Customer in seated_customers:
				_send_customer_to_exit(seated_customer)

		# 3. Fait avancer la file et fait sortir le payeur actuel
		_advance_queue()
		_send_customer_to_exit(customer)
		
		# Petit délai pour fluidifier visuellement le passage du client suivant
		await get_tree().create_timer(level_data.queue_advance_delay, false).timeout
		_advance_queue()

	# Enregistrement des gains globaux et affichage du feedback UI
	if total_bill_batch > 0.0:
		EarningsManager.add_earnings(total_bill_batch, total_tip_batch)
		feedback_display.show_payment(total_bill_batch, total_tip_batch, total_combo_bonus)


# ==============================================================================
# --- EXPIRATION DE PATIENCE & SORTIES ---
# ==============================================================================

## Déclenché si la patience d'un client en file expire avant d'être encaissé.
func on_queue_patience_expired(customer: Customer, table: TableComponent) -> void:
	_remove_customer_from_queue(customer)

	if table != null:
		# Si client de table : tout le groupe s'en va sans payer, la table redevient sale
		var group: Array[Customer] = table.order_component.seated_customers.duplicate()
		for member: Customer in group:
			member.patience_component.cancel()
		CustomerExitService.release_table(table)
		for member: Customer in group:
			_send_customer_to_exit(member)
	else:
		# Si client de comptoir : quitte simplement la scène
		_send_customer_to_exit(customer)

	_advance_queue()


## Retire un client spécifique de la structure de données de la file.
func _remove_customer_from_queue(customer: Customer) -> void:
	for i: int in range(_queue.size()):
		if _queue[i]["customer"] == customer:
			_queue.remove_at(i)
			return


## Envoie un client vers la sortie et émet le signal `customer_exited` une fois la sortie terminée.
func _send_customer_to_exit(customer: Customer) -> void:
	CustomerExitService.send_customer_to_exit(
		customer, exit_marker,
		func() -> void: customer_exited.emit()
	)


## Repositionne chaque client de la file vers son marqueur `queue_positions[i]` correspondant.
func _advance_queue() -> void:
	for i: int in range(_queue.size()):
		var entry: Dictionary = _queue[i]
		var customer: Customer = entry["customer"]
		
		if not is_instance_valid(customer):
			continue # Sécurité : ignore l'élément si le nœud a été détruit
		
		if i < queue_positions.size():
			var state: GameEnums.CustomerState = GameEnums.CustomerState.PAYING if entry["is_served"] else GameEnums.CustomerState.MOVING
			customer.move_to(queue_positions[i], state)


## Déclenché dès que le joueur clique sur la caisse (avant même d'y être arrivé).
## Met en pause la patience des clients pour ne pas pénaliser le joueur durant son temps de trajet.
func _on_action_queued(_action_id: int) -> void:
	for entry: Dictionary in _queue:
		entry["customer"].patience_component.cancel()
