extends Node

signal earnings_updated

var daily_earnings: float = 0.0
var tip_fund: float = 0.0

func add_earnings(bill: float, tip: float) -> void:
	daily_earnings += bill + tip
	tip_fund += tip
	earnings_updated.emit()
