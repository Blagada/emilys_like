extends Node2D
class_name OrderComponent

# --- EXPORTS & CONFIGURATIONS ---
@export var order_bubble: OrderBubbleComponent

# --- SIGNAUX ---
signal all_orders_served

# --- VARIABLES D'ÉTAT ---
var seated_customers: Array[Customer] = [] # Liste des clients assis à cette table
var total_bill: float = 0.0                # Montant total de l'addition pour cette table


# --- VÉRIFICATION DE LA PRÉSENCE D'UN CLIENT SERVABLE ---
# Vérifie s'il y a au moins un client à table dont la commande correspond à un plat présent sur le plateau
func has_servable_customer() -> bool:
	for customer: Customer in seated_customers:
		if customer.current_order != null and TrayManager.tray_items.has(customer.current_order):
			return true
	return false


# --- COMPTE LE NOMBRE D'ÉLÉMENTS SERVABLES ---
# Parcourt les clients et compte combien d'entre eux peuvent être servis immédiatement avec les plats du plateau
func count_servable_items() -> int:
	var count_servable_item: int = 0
	for customer: Customer in seated_customers:
		if customer.current_order != null and TrayManager.tray_items.has(customer.current_order):
			count_servable_item += 1
	return count_servable_item


# --- DISTRIBUTION DES PLATS AUX CLIENTS ---
# Sert les plats du plateau aux clients correspondants, met à jour le plateau et vérifie si tout le monde a été servi
func serve_food() -> void:
	var served_someone: bool = false

	for customer: Customer in seated_customers:
		if customer.current_order == null:
			continue

		# Si le plat commandé par le client est sur le plateau, on le retire du plateau et de la commande
		if TrayManager.tray_items.has(customer.current_order):
			TrayManager.tray_items.erase(customer.current_order)
			customer.current_order = null
			customer.patience_component.cancel()
			served_someone = true

	# Si personne n'a pu être servi, on arrête ici
	if not served_someone:
		return

	# On notifie que le plateau a changé et on met à jour l'affichage de la bulle
	TrayManager.tray_updated.emit()
	update_order_bubble()

	# Si tous les clients de la table ont reçu leur plat, on émet le signal correspondant
	if _all_customers_served():
		all_orders_served.emit()
	else:
		# Certain client on été servi, mais pas tous
		for customer: Customer in seated_customers:
			if customer and customer.current_order != null:
				var current_patience_state = customer.patience_component.get_current_state()
				customer.patience_component.start(customer.customer_data.patience, current_patience_state)
				update_patience_icon(current_patience_state)

# --- VÉRIFIE SI TOUS LES CLIENTS ONT ÉTÉ SERVIS ---
# Retourne vrai si aucun client de la table n'a de commande en attente
func _all_customers_served() -> bool:
	for customer: Customer in seated_customers:
		if customer.current_order != null:
			return false
	return true


# --- MISE À JOUR DE LA BULLE DE COMMANDE ---
# Rassemble toutes les commandes en cours des clients et les affiche dans la bulle
func update_order_bubble() -> void:
	var orders: Array[FoodData] = []
	for customer: Customer in seated_customers:
		if customer.current_order != null:
			orders.append(customer.current_order)
	order_bubble.show_orders(orders)


# --- AFFICHAGE DE L'ÉTAT DE RÉFLEXION ("...") ---
func show_thinking() -> void:
	order_bubble.show_thinking()


# --- AFFICHAGE DE L'ÉTAT SALE/ATTENTE DE PAIEMENT ("!") ---
func show_dirty() -> void:
	order_bubble.show_dirty()


# --- SUPPRESSION DE LA BULLE DE L'ÉCRAN ---
func hide_order_bubble() -> void:
	order_bubble.hide_bubble()


func update_patience_icon(state: GameEnums.PatienceState) -> void:
	order_bubble.update_patience_icon(state)
