extends Control
class_name LevelIntroScreen

signal day_started

@export var restaurant_name_label: Label
@export var level_number_label: Label
@export var table_info_label: RichTextLabel
@export var services_label: RichTextLabel
@export var customers_list_label: RichTextLabel
@export var tray_label: RichTextLabel
@export var goal_label: RichTextLabel
@export var start_button: Button
@export var menu_list_label: RichTextLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)


func setup(level_data: LevelData, table_count: int, total_seats: int, daily_goal: float, expert_goal: float) -> void:
	restaurant_name_label.text = "Restaurant %s" % level_data.restaurant.restaurant_name
	level_number_label.text = "Jour %d" % level_data.level_number
	table_info_label.text = "[b]Nombre de tables[/b] : %d tables (%d places)" % [table_count, total_seats]
	services_label.text = "[b]Service[/b] du %s" % _format_services(level_data.active_services)
	tray_label.text = "[b]Espace sur le plateau[/b] : %d" % level_data.tray_max_capacity
	customers_list_label.text = "[b]Type de clients[/b] : %s" % _format_customers(level_data.possible_customers)
	goal_label.text = "[b]Objectif[/b] : %.0f$ (expert : %.0f$)" % [daily_goal, expert_goal]
	menu_list_label.text = "[b]Menu[/b] :\n" + _format_menu(level_data.level_menu)


func _on_start_pressed() -> void:
	day_started.emit()
	queue_free()


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
