class_name DailyGoalHelper

const TABLE_ITEMS_PER_CUSTOMER: float = 1.0
const AVERAGE_GROUP_SIZE: float = 2.5 # randi_range(1, 4), uniforme
const ROUNDED_GOAL: float = 25.0

static func compute_daily_goal(
	level_data: LevelData,
	table_count: int,
	avg_travel_time: float,
	avg_customer_speed: float,
	avg_cleaning_duration: float,
	sitting_animation_delay: float,
	bill_display_duration: float,
	day_duration: float,
	expert_threshold_percent: float
) -> Dictionary:
	var avg_food_price: float = _average_food_price(level_data.level_menu)
	var avg_tip_rate: float = _average_tip_rate(level_data.possible_customers)
	var revenue_per_group: float = avg_food_price * TABLE_ITEMS_PER_CUSTOMER * AVERAGE_GROUP_SIZE * (1.0 + avg_tip_rate)

	var order_delay: float = 500.0 / avg_customer_speed
	var eating_delay: float = 800.0 / avg_customer_speed
	var cycle_duration: float = (avg_travel_time * 2.0) + sitting_animation_delay + order_delay + eating_delay + bill_display_duration + avg_cleaning_duration

	var cycles_possible: float = 0.0
	if cycle_duration > 0.0:
		cycles_possible = day_duration / cycle_duration

	var max_theoretical_revenue: float = cycles_possible * table_count * revenue_per_group

	var difficulty_percent: float = _difficulty_percent(level_data.level_number, level_data.restaurant.total_levels)
	var daily_goal: float = snapped(max_theoretical_revenue * difficulty_percent, ROUNDED_GOAL)
	var expert_goal: float = snapped(daily_goal * (expert_threshold_percent / 100.0), ROUNDED_GOAL)

	return {
		"daily_goal": daily_goal,
		"expert_goal": expert_goal,
		"max_theoretical_revenue": max_theoretical_revenue,
		"cycle_duration": cycle_duration
	}


static func _average_food_price(level_menu: LevelMenu) -> float:
	if level_menu.available_foods.is_empty():
		return 0.0

	var total: float = 0.0
	for food: FoodData in level_menu.available_foods:
		total += food.price

	return total / level_menu.available_foods.size()


static func _average_tip_rate(possible_customers: Array[CustomerData]) -> float:
	if possible_customers.is_empty():
		return 0.0

	var total: float = 0.0
	for data: CustomerData in possible_customers:
		total += data.tip_rate

	return total / possible_customers.size()


static func _difficulty_percent(level_number: int, total_levels: int) -> float:
	if total_levels <= 1:
		return 0.4

	var progress: float = float(level_number - 1) / float(total_levels - 1)
	return lerp(0.4, 0.8, clampf(progress, 0.0, 1.0))
