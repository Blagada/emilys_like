class_name CustomerExitService
# Logique pure de sortie de client, indépendante du contexte (table, comptoir, file d'attente).

# --- LIBÈRE UNE TABLE APRÈS LE DÉPART DE SES CLIENTS ---
static func release_table(table: TableComponent) -> void:
	table.occupied_seats.clear()
	table.order_component.seated_customers.clear()
	table.order_component.hide_order_bubble()
	table.current_state = GameEnums.TableState.WAITING_FOR_CLEANING if table.is_dirty else GameEnums.TableState.UNOCCUPIED_AND_CLEAN
	print("table.current_state ", table.current_state)


# --- FAIT SORTIR UN CLIENT PAR LE MARKER DE SORTIE, PUIS LE RETIRE DE LA SCÈNE ---
static func send_customer_to_exit(customer: Customer, exit_marker: Marker2D) -> void:
	await customer.move_to(exit_marker, GameEnums.CustomerState.MOVING)
	customer.queue_free()
