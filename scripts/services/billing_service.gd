class_name BillingService

# Retourne {bill, tip, combo_bonus} pour un client donné.
static func compute_transaction(
	base_price: float,
	tip_rate: float,
	patience_state: GameEnums.PatienceState,
	combo_index: int,
	bonus_per_extra: float,
	max_percent: float,
	is_single_trip: bool,
	single_trip_bonus_percent: float
) -> Dictionary:
	var combo_bonus: float = BonusService.compute_combo_bonus(base_price, combo_index, bonus_per_extra, max_percent)
	var single_trip_bonus = BonusService.compute_single_trip_bonus(base_price, is_single_trip, single_trip_bonus_percent)
	var bill: float = base_price + combo_bonus + single_trip_bonus
	var tip: float = bill * tip_rate * BonusService.compute_patience_tip_modifier(patience_state)
	return {"bill": bill, "tip": tip, "combo_bonus": combo_bonus, "single_trip_bonus": single_trip_bonus}
