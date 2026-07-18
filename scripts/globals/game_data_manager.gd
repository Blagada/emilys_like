extends Node

signal tray_updated

# --- DONNÉES ---
var tray_items: Array[FoodData] = []
var current_max_capacity: int = 3 # Dépent du niveau

# --- RESET ---
# Remet le tray à 0 (principalement au changement de niveau)
func clear_tray():
	tray_items.clear()
