extends Node

# le plateau est mis à jour
signal tray_updated
# le montant gagné est mis à jour
signal earnings_updated
signal pending_updated

# --- DONNÉES ---
var tray_items: Array[FoodData] = []
var current_max_capacity: int = 3 # Dépent du niveau
var item_target_size: int = 64

var daily_earnings: float = 0.0 # bill + tip, cumulé sur la journée
var tip_fund: float = 0.0 # cagnotte dédiée à la déco, cumulée entre les journées
var pending_items: Array[Dictionary] = [] # {action_id, food_data, cancel_requested}

# --- TRAY ---
# Remet le tray à 0 (principalement au changement de niveau)
func clear_tray():
	tray_items.clear()
	tray_updated.emit()

# --- DAILYGOAL ---
# calcul le montant total gagné durant la journée + sépare le tip dans une valeur séparé
func add_earnings(bill: float, tip: float) -> void:
	daily_earnings += bill + tip
	tip_fund += tip
	earnings_updated.emit()


func add_pending_item(action_id: int, food_data: FoodData) -> void:
	pending_items.append({"action_id": action_id, "food_data": food_data, "cancel_requested": false})
	pending_updated.emit()


func request_cancel_pending_item(action_id: int) -> void:
	for entry: Dictionary in pending_items:
		if entry["action_id"] == action_id:
			entry["cancel_requested"] = true
			return


func remove_pending_item(action_id: int) -> void:
	for i: int in range(pending_items.size()):
		if pending_items[i]["action_id"] == action_id:
			pending_items.remove_at(i)
			pending_updated.emit()
			return


func consume_pending_item(action_id: int) -> bool:
	for i: int in range(pending_items.size()):
		if pending_items[i]["action_id"] == action_id:
			var was_cancelled: bool = pending_items[i]["cancel_requested"]
			pending_items.remove_at(i)
			pending_updated.emit()
			return was_cancelled
	return false
