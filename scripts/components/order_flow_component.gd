extends Node
class_name OrderFlowComponent

# --- RÉFÉRENCES DES COMPOSANTS ET GESTIONNAIRES ---
@export_group("Scripts")
@export var customer_spawner: SpawnComponent
@export var payment_queue: PaymentQueueComponent
@export var waiting_queue: WaitingQueueComponent
@export var day_cycle: DayCycleComponent


@onready var level_manager: LevelComponent = get_tree().get_first_node_in_group("LevelManager")


## Initialise le composant au lancement.
## Connecte le signal d'apparition des clients et initialise l'écoute du service des commandes pour chaque table de la scène.
func _ready() -> void:
	customer_spawner.group_spawned.connect(_on_customer_group_spawned)

	for table_node: Node in get_tree().get_nodes_in_group("Table"):
		var table_comp = table_node.get_node_or_null("TableComponent")
		if table_comp:
			table_comp.order_component.all_orders_served.connect(_on_all_orders_served.bind(table_comp))


# --- GESTION DE L'ARRIVÉE D'UN GROUPE DE CLIENTS ---
## Déclenché lorsqu'un groupe de clients apparaît. 
## Tente de leur assigner une table ; si aucune n'est libre, les place dans la file d'attente.
func _on_customer_group_spawned(group: Array[Customer]) -> void:
	var all_tables: Array[Node] = get_tree().get_nodes_in_group("Table")
	var assigned_table: TableComponent = TableAssignmentService.choose_table(all_tables, group.size())

	if assigned_table == null:
		waiting_queue.enqueue_group(group)
		return

	seat_group(assigned_table, group)


# --- DÉROULEMENT DE LA COMMANDE À TABLE ---
## Gère le processus complet de prise de commande d'un groupe assis à une table (attente, réflexion, choix des plats et gestion de la patience).
func _handle_group_ordering(assigned_table: TableComponent, group: Array[Customer]) -> void:
	for customer: Customer in group:
		if not customer.movement_component.has_arrived():
			await customer.movement_component.destination_reached

	await get_tree().create_timer(level_manager.sitting_animation_delay, false).timeout
	for customer: Customer in group:
		customer.change_state(GameEnums.CustomerState.WAITING_TO_ORDER)
	assigned_table.order_component.show_thinking()

	var order_delay: float = 500.0 / group[0].customer_data.speed
	await get_tree().create_timer(order_delay, false).timeout

	for customer: Customer in group:
		var food: FoodData = _get_food_for_customer(customer)
		customer.set_order(food)
		assigned_table.order_component.total_bill += food.price
		customer.change_state(GameEnums.CustomerState.ORDERING)
		customer.patience_component.start(customer.customer_data.patience)
		customer.patience_component.patience_expired.connect(
			_on_group_patience_expired.bind(group, assigned_table)
		)
		
		if customer == group[0]:
			customer.patience_component.patience_state_changed.connect(
				assigned_table.order_component.update_patience_icon
			)

	assigned_table.order_component.update_order_bubble()

## Détermine le plat commandé par un client en fonction de ses restrictions ou requis potentiels.
func _get_food_for_customer(customer: Customer) -> FoodData:
	var menu = level_manager.level_data.level_menu
	
	# Récupère tous les plats disponibles dans le menu du niveau
	# (Assure-toi d'avoir une méthode comme get_all_foods() ou adapte selon ton code existant)
	var all_foods: Array[FoodData] = menu.get_all_food()
	var valid_foods: Array[FoodData] = []
	
	for food: FoodData in all_foods:
		var is_valid: bool = true
		
		# 1. On vérifie d'abord les interdictions (Forbidden)
		for tag: GameEnums.FoodTag in customer.customer_visual.forbidden_tags:
			if food.has_tag(tag):
				is_valid = false
				break # Trouvé un tag interdit, pas la peine de chercher plus loin pour ce plat
		
		# Si le plat a un tag interdit, il est rejeté instantanément. 
		# On passe au plat suivant sans vérifier les requis.
		if not is_valid:
			continue
			
		# 2. Ensuite, on vérifie les requis (Required)
		# Le plat doit posséder les tags exigés par le client
		for tag: GameEnums.FoodTag in customer.customer_visual.required_tags:
			if not food.has_tag(tag):
				is_valid = false # Il manque un tag requis obligatoire
				break

		# Si le plat a survécu à tous les tests, on l'ajoute !
		if is_valid:
			valid_foods.append(food)

	# Si on a trouvé des plats correspondants, on en choisit un au hasard parmi eux
	if not valid_foods.is_empty():
		return valid_foods.pick_random()

	# --- AUCUN PLAT NE CORRESPOND ---
	print("Attention : Aucun plat ne correspond aux critères de ce client !")
	# TODO : ajouter une fonction qui gère le cas qu'aucun repas du menu ne correspond. Valider si des gens à la table peuvent manger, et changer le comportement.
	return all_foods.pick_random()


# --- FIN DU SERVICE DES PLATS (PASSAGE AU REPAS) ---
## Déclenché lorsque tous les plats d'une table ont été servis. 
## Fait passer les clients à l'état de repas, puis, après un délai, les amène à l'attente du paiement.
func _on_all_orders_served(table: TableComponent) -> void:
	table.current_state = GameEnums.TableState.IN_MEAL
	var customers: Array[Customer] = table.order_component.seated_customers

	for customer: Customer in customers:
		customer.change_state(GameEnums.CustomerState.EATING)

	var eating_delay: float = 800.0 / customers[0].customer_data.speed
	await get_tree().create_timer(eating_delay, false).timeout

	for customer: Customer in customers:
		customer.change_state(GameEnums.CustomerState.WAITING_FOR_PAYMENT)

	table.order_component.show_dirty()
	table.current_state = GameEnums.TableState.WAITING_FOR_PAYMENT
	payment_queue.enqueue(customers[0], table)


## Gère l'expiration de la patience du groupe (clients mécontents qui s'en vont). 
## Annule leur patience, libère la table et renvoie les clients vers la sortie.
func _on_group_patience_expired(group: Array[Customer], table: TableComponent) -> void:
	for customer: Customer in group:
		if is_instance_valid(customer):
			customer.patience_component.cancel()

	CustomerExitService.release_table(table)

	for customer: Customer in group:
		if is_instance_valid(customer):
			_send_customer_away(customer)


## Envoie un client spécifique vers la sortie du restaurant en utilisant le service dédié.
func _send_customer_away(customer: Customer) -> void:
	CustomerExitService.send_customer_to_exit(
		customer,
		payment_queue.exit_marker,
		func() -> void: payment_queue.customer_exited.emit()
	)


# --- ASSIGNE UN GROUPE À UNE TABLE DÉJÀ CHOISIE (réutilisable : spawn direct OU file d'attente) ---
## Installe un groupe de clients à une table assignée, réserve leurs sièges, initialise leur facture et lance leur déplacement vers la table.
func seat_group(assigned_table: TableComponent, group: Array[Customer]) -> void:
	var seats: Array[Marker2D] = assigned_table.reserve_seats(group.size())

	if seats.size() != group.size():
		return

	for i: int in range(group.size()):
		var customer: Customer = group[i]
		assigned_table.order_component.seated_customers.append(customer)
		assigned_table.is_dirty = true
		assigned_table.order_component.total_bill = 0.0
		assigned_table.order_component.service_visit_count = 0
		customer.move_to_table(seats[i], assigned_table.global_position)
		day_cycle.register_customer_spawned()

	_handle_group_ordering(assigned_table, group)
