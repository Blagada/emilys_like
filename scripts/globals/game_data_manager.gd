extends Node

signal tray_updated

# --- DONNÉES ---
var tray_items: Array[FoodData] = []
var current_max_capacity: int = 3 # Dépent du niveau
var item_target_size: int = 64

var daily_earnings: float = 0.0 # bill + tip, cumulé sur la journée
var tip_fund: float = 0.0 # cagnotte dédiée à la déco, cumulée entre les journées

# --- RESET ---
# Remet le tray à 0 (principalement au changement de niveau)
func clear_tray():
	tray_items.clear()
	tray_updated.emit()
