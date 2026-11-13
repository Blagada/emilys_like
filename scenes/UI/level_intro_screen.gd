extends Control
class_name LevelIntroScreen

signal day_started

@export var level_bar: LevelBar

@export var level_number_label: Label
@export var table_info_label: RichTextLabel
@export var services_label: RichTextLabel
@export var customers_list_label: RichTextLabel
@export var tray_label: RichTextLabel
@export var goal_label: RichTextLabel
@export var menu_list_label: RichTextLabel


func _ready() -> void:
	# Se connecte au signal des boutons de la bar de menu
	level_bar.primary_pressed.connect(_on_primary_pressed)
	level_bar.catalog_pressed.connect(_on_catalog_pressed)
	level_bar.visit_pressed.connect(_on_visit_pressed)
	# Envoie le focus sur le primary button
	level_bar.primary_button.grab_focus()
	visible = false


func setup(level_data: LevelData, table_count: int, total_seats: int, daily_goal: float, expert_goal: float) -> void:
	texts_setup(level_data, table_count, total_seats, daily_goal, expert_goal)
	visible = true


func texts_setup(level_data: LevelData, table_count: int, total_seats: int, daily_goal: float, expert_goal: float) -> void:
	level_number_label.text = tr("LEVEL_DAY") % level_data.level_number
	table_info_label.text = tr("TABLES_INFO") % [table_count, total_seats]
	services_label.text = tr("SERVICES_INFO") % _format_services(level_data.active_services)
	tray_label.text = tr("TRAY_INFO") % level_data.tray_max_capacity
	goal_label.text = tr("GOAL_INFO") % [CurrencyService.format(daily_goal, 0), CurrencyService.format(expert_goal, 0)]
	customers_list_label.text = "[b]Type de clients[/b] : %s" % _format_customers(level_data.possible_customers)
	menu_list_label.text = "[b]Menu[/b] :\n" + _format_menu(level_data.level_menu)


func _on_primary_pressed() -> void:
	day_started.emit()
	queue_free()


func _on_catalog_pressed() -> void:
	print("Ouvrir le catalogue")

	
func _on_visit_pressed() -> void:
	print("Lancer la visite")


# Vérifie les types de services disponible et les énumères
func _format_services(services: Array[GameEnums.ServiceType]) -> String:
	var names: Array[String] = []
	for service: GameEnums.ServiceType in services:
		names.append(GameEnums.SERVICE_TYPE_LABELS.get(service, "?"))
	return _join_with_and(names)


# Vérifier le nombre de type de client, et les énumères
func _format_customers(customers: Array[CustomerData]) -> String:
	var names: Array[String] = []
	for data: CustomerData in customers:
		names.append(GameEnums.CUSTOMER_TYPE_LABELS.get(data.group_type, "?"))
	return _join_with_and(names)


func _format_menu(level_menu: LevelMenu) -> String:
	var names: Array[String] = []
	for food: FoodData in level_menu.available_foods:
		names.append("%s (%.2f$)" % [food.name, food.price])
	return " \n".join(names)


func _join_with_and(items: Array[String]) -> String:
	if items.is_empty():
		return ""
	if items.size() == 1:
		return items[0]

	var all_but_last: Array[String] = items.slice(0, items.size() - 1)
	return ", ".join(all_but_last) + " et " + items[items.size() - 1]
