class_name BonusService

# Calcule le bonus combo sur une facture, selon l'index du client dans le lot payé.
static func compute_combo_bonus(bill: float, combo_index: int, bonus_per_extra: float, max_percent: float) -> float:
	var combo_percent: float = min(bonus_per_extra * combo_index, max_percent)
	return bill * combo_percent

static func compute_single_trip_bonus(bill: float, is_single_trip: bool, bonus_percent: float) -> float:
	if is_single_trip:
		return bill * bonus_percent
	return 0.0

static func compute_patience_tip_modifier(patience_state: GameEnums.PatienceState) -> float:
	# TODO : retourner le multiplicateur selon l'état (1.0 / 0.5 / 0.0)
	match patience_state:
		GameEnums.PatienceState.HAPPY:
			return 1
		GameEnums.PatienceState.IMPATIENT:
			return 0.5
		GameEnums.PatienceState.ANGRY:
			return 0
		_: # Fallback sur le multiplicateur régulier
			return 1
