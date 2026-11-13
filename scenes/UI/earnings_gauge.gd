extends Control
class_name EarningsGauge

@export var progress_bar: ProgressBar
@export var amount_label: Label
@export_range(0.0, 0.5) var headroom_percent: float = 0.15

@export_group("Daily goal")
@export var goal_marker: Control
@export var goal_value_label: Label
@export var goal_star: TextureRect

@export_group("Expert goal")
@export var expert_goal_marker: Control
@export var expert_value_label: Label
@export var expert_star: TextureRect

var daily_goal_amount: float = 0.0
var expert_goal_amount: float = 0.0

func setup(daily_goal: float, expert_goal: float) -> void:
	daily_goal_amount = daily_goal
	expert_goal_amount = expert_goal

	progress_bar.max_value = expert_goal * (1.0 + headroom_percent)
	progress_bar.step = 0.0
	progress_bar.value = EarningsManager.daily_earnings
	goal_star.visible = false
	expert_star.visible = false

	_place_marker(goal_marker, daily_goal)
	_place_marker(expert_goal_marker, expert_goal)
	texts_setup(daily_goal, expert_goal)

	EarningsManager.earnings_updated.connect(_on_earnings_updated)
	_on_earnings_updated()


func texts_setup(daily_goal: float, expert_goal: float) -> void:
	goal_value_label.text = CurrencyService.format(daily_goal, 0)
	expert_value_label.text = CurrencyService.format(expert_goal, 0)
	amount_label.text = CurrencyService.format(EarningsManager.daily_earnings)
	

func _on_earnings_updated() -> void:
	var earned: float = EarningsManager.daily_earnings

	progress_bar.value = EarningsManager.daily_earnings
	amount_label.text = CurrencyService.format(EarningsManager.daily_earnings)
	
	goal_star.visible = earned >= daily_goal_amount
	expert_star.visible = earned >= expert_goal_amount


func _place_marker(marker: Control, amount: float) -> void:
	var ratio: float = amount / progress_bar.max_value
	marker.anchor_top = 1.0 - ratio
	marker.anchor_bottom = 1.0 - ratio
