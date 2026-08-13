class_name BonusService

# Calcule le bonus combo sur une facture, selon l'index du client dans le lot payé.
static func compute_combo_bonus(bill: float, combo_index: int, bonus_per_extra: float, max_percent: float) -> float:
	var combo_percent: float = min(bonus_per_extra * combo_index, max_percent)
	return bill * combo_percent

# TODO (futur, pas pour maintenant) :
# static func compute_single_trip_bonus(...) -> float
# static func compute_patience_tip_modifier(...) -> float
