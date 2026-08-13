class_name BillingService

# Retourne {bill, tip, combo_bonus} pour un client donné.
static func compute_transaction(base_price: float, tip_rate: float, combo_index: int, bonus_per_extra: float, max_percent: float) -> Dictionary:
	var combo_bonus: float = BonusService.compute_combo_bonus(base_price, combo_index, bonus_per_extra, max_percent)
	var bill: float = base_price + combo_bonus
	var tip: float = bill * tip_rate
	return {"bill": bill, "tip": tip, "combo_bonus": combo_bonus}
