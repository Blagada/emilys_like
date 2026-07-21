extends Node
class_name StaffComponent

signal state_changed(new_state: GameEnums.StaffState)

var current_state: GameEnums.StaffState = GameEnums.StaffState.WAITING:
	set(value):
		if current_state == value:
			return
		current_state = value
		state_changed.emit(value)


func start_task(state: GameEnums.StaffState, duration: float) -> void:
	current_state = state

	await get_tree().create_timer(duration).timeout

	current_state = GameEnums.StaffState.WAITING


func set_moving() -> void:
	if _is_busy_with_task():
		return
	current_state = GameEnums.StaffState.MOVING


func set_idle() -> void:
	if _is_busy_with_task():
		return
	current_state = GameEnums.StaffState.WAITING


func _is_busy_with_task() -> bool:
	return current_state in [
		GameEnums.StaffState.FOOD_PREP,
		GameEnums.StaffState.DELIVERING,
		GameEnums.StaffState.CLEANING,
	]
