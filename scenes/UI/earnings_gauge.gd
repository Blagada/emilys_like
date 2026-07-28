extends Control
class_name EarningsGauge

@export var progress_bar: ProgressBar
@export var goal_marker: Control
@export var amount_label: Label

var expert_amount: float = 0.0


func setup(daily_goal: float, expert_threshold_percent: float) -> void:
	expert_amount = daily_goal * (expert_threshold_percent / 100.0)
	progress_bar.max_value = expert_amount
	progress_bar.value = EarningsManager.daily_earnings

	var goal_ratio: float = daily_goal / expert_amount
	goal_marker.anchor_left = goal_ratio
	goal_marker.anchor_right = goal_ratio

	EarningsManager.earnings_updated.connect(_on_earnings_updated)
	_on_earnings_updated()


func _on_earnings_updated() -> void:
	progress_bar.value = EarningsManager.daily_earnings
	amount_label.text = "%.2f$ / %.2f$" % [EarningsManager.daily_earnings, expert_amount]
