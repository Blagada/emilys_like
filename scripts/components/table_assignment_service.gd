class_name TableAssignmentService
# Logique pure de sélection de table, indépendante de tout niveau spécifique.

# Retourne toutes les tables capables d'accueillir le groupe (libres + assez de chaises)
static func get_valid_tables(all_tables: Array[Node], group_size: int) -> Array[TableComponent]:
	var valid_tables: Array[TableComponent] = []
	for table_node: Node in all_tables:
		var table_comp: TableComponent = table_node.get_node_or_null("TableComponent")
		if table_comp and table_comp.can_accommodate_group(group_size):
			valid_tables.append(table_comp)
	return valid_tables


# Filtre pour ne garder que les tables de capacité optimale (ni trop grandes, ni trop petites)
static func filter_optimal_tables(valid_tables: Array[TableComponent], group_size: int) -> Array[TableComponent]:
	var target_capacity: int = 2 if group_size <= 2 else 4
	return valid_tables.filter(func(t: TableComponent) -> bool:
		return t.all_chair_positions.size() == target_capacity
	)


# Choisit la meilleure table disponible pour un groupe. Retourne null si aucune table ne convient.
static func choose_table(all_tables: Array[Node], group_size: int) -> TableComponent:
	var valid_tables: Array[TableComponent] = get_valid_tables(all_tables, group_size)
	if valid_tables.is_empty():
		return null

	var optimal_tables: Array[TableComponent] = filter_optimal_tables(valid_tables, group_size)
	var chosen_pool: Array[TableComponent] = optimal_tables if not optimal_tables.is_empty() else valid_tables

	return chosen_pool.pick_random() as TableComponent
