extends Node2D
class_name OrderComponent

@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

signal all_orders_served

var seated_customers: Array[Customer] = [] # type de client assis à table
var total_bill: float = 0.0
var order_bubble: Node = null


# Vérifie s'il y a au moins un client qu'on pourrait servir avec le plateau actuel
func has_servable_customer() -> bool:
	for customer: Customer in seated_customers:
		if customer.current_order != null and TrayManager.tray_items.has(customer.current_order):
			return true
	return false


func serve_food() -> void:
	print("DEBUG: serve_food() appelée, ", seated_customers.size(), " client(s) à cette table")
	var served_someone: bool = false

	for customer: Customer in seated_customers:
		if customer.current_order == null:
			continue

		if TrayManager.tray_items.has(customer.current_order):
			TrayManager.tray_items.erase(customer.current_order)
			customer.current_order = null
			served_someone = true

	if not served_someone:
		print("Rien à servir : aucun item du plateau ne correspond aux commandes en attente")
		return

	TrayManager.tray_updated.emit()
	update_order_bubble()

	if _all_customers_served():
		all_orders_served.emit()


func _all_customers_served() -> bool:
	for customer: Customer in seated_customers:
		if customer.current_order != null:
			return false
	return true


func update_order_bubble() -> void:
	var orders: Array[FoodData] = []
	for customer: Customer in seated_customers:
		if customer.current_order != null:
			orders.append(customer.current_order)

	if orders.is_empty():
		hide_order_bubble()
		return

	_ensure_bubble_instance()
	order_bubble.show_orders(orders)


func show_thinking() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("...")


func show_dirty() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("!")


func hide_order_bubble() -> void:
	if order_bubble:
		order_bubble.queue_free()
		order_bubble = null


func _ensure_bubble_instance() -> void:
	if order_bubble == null:
		order_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(order_bubble)
