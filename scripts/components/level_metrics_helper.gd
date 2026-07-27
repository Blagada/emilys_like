class_name LevelMetricsHelper

static func compute_metrics(navigation_region: NavigationRegion2D, customer_spawner: SpawnComponent, possible_customers: Array) -> Dictionary:
	var nav_map: RID = navigation_region.get_world_2d().navigation_map
	
	# On s'assure que la carte de navigation a fait au moins une itération avant d'interroger
	while NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		await navigation_region.get_tree().physics_frame

	# Ensuite, on valide la proximité comme avant
	var reference_point: Vector2 = customer_spawner.spawn_point.global_position
	for i: int in range(20):
		var closest: Vector2 = NavigationServer2D.map_get_closest_point(nav_map, reference_point)
		if closest.distance_to(reference_point) < 5.0:
			break
		await navigation_region.get_tree().physics_frame

	var tables: Array = navigation_region.get_tree().get_nodes_in_group("Table")
	var table_count: int = tables.size()
	var total_seats: int = 0

	var travel_times: Array[float] = []
	var reference_speed: float = _average_customer_speed(possible_customers)

	for table_node: Node in tables:
		var table_comp = table_node.get_node_or_null("TableComponent")
		if not table_comp:
			continue

		total_seats += table_comp.all_chair_positions.size()

		var travel_time: float = _measure_travel_time(
			customer_spawner.spawn_point.global_position,
			table_comp.interaction_component.interaction_point.global_position,
			reference_speed,
			nav_map
		)
		if travel_time > 0.0:
			travel_times.append(travel_time)

	var avg_customer_travel_time: float = 0.0
	if not travel_times.is_empty():
		var total: float = 0.0
		for t: float in travel_times:
			total += t
		avg_customer_travel_time = total / travel_times.size()

	return {
		"table_count": table_count,
		"total_seats": total_seats,
		"avg_customer_travel_time": avg_customer_travel_time
	}


static func _measure_travel_time(from: Vector2, to: Vector2, speed: float, nav_map: RID) -> float:
	var path: PackedVector2Array = NavigationServer2D.map_get_path(nav_map, from, to, true)
	print("nav_map valide : ", nav_map.is_valid(), " | from : ", from, " | to : ", to, " | path.size() : ", path.size())

	if path.size() < 2 or speed <= 0.0:
		return 0.0

	var distance: float = 0.0
	for i: int in range(path.size() - 1):
		distance += path[i].distance_to(path[i + 1])
	return distance / speed


static func _average_customer_speed(possible_customers: Array) -> float:
	if possible_customers.is_empty():
		return 100.0

	var total: float = 0.0
	for data: CustomerData in possible_customers:
		total += data.speed

	return total / possible_customers.size()
