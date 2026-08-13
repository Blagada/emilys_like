extends Node
class_name CounterOrderFlowComponent

@export var payment_queue: PaymentQueueComponent


# Fait réfléchir puis commander un client de comptoir. `entry` est le Dictionary
# de PaymentQueueComponent._queue pour ce client (modifié en place, car les
# Dictionary sont passés par référence en GDScript).
func take_order(customer: Customer, level_menu: LevelMenu, entry: Dictionary) -> void:
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
		payment_queue.on_queue_patience_expired.bind(customer, null)
	)
