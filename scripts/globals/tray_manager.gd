extends Node

signal tray_updated
signal pending_updated

var tray_items: Array[FoodData] = []
var pending_items: Array[Dictionary] = []
var current_max_capacity: int = 3
var item_target_size: int = 64


func clear_tray() -> void:
	tray_items.clear()
	tray_updated.emit()


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
