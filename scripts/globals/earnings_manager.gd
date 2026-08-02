extends Node

signal earnings_updated

var daily_earnings: float = 0.0
var tip_fund: float = 0.0
var daily_tip: float = 0.0


func add_earnings(bill: float, tip: float) -> void:
	daily_earnings += bill + tip
	daily_tip += tip
	tip_fund += tip
	earnings_updated.emit()


func apply_expert_tip_bonus(multiplicator) -> float:
	return snapped(daily_tip, 5.0) * multiplicator


func reset_daily() -> void:
	daily_earnings = 0.0
	daily_tip = 0.0
