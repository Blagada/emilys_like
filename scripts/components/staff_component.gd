extends Node
class_name StaffComponent

signal state_changed(new_state: GameEnums.StaffState)

@export var countdown_label: Label

var current_state: GameEnums.StaffState = GameEnums.StaffState.WAITING:
	set(value):
		if current_state == value:
			return
		current_state = value
		state_changed.emit(value)


func start_task(state: GameEnums.StaffState, duration: float) -> void:
	current_state = state

	var elapsed: float = 0.0
	_update_countdown(duration)

	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		_update_countdown(max(duration - elapsed, 0.0))

	current_state = GameEnums.StaffState.WAITING
	_hide_countdown()


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


func _update_countdown(remaining: float) -> void:
	if countdown_label:
		countdown_label.visible = true
		countdown_label.text = "%.2f" % remaining


func _hide_countdown() -> void:
	if countdown_label:
		countdown_label.visible = false
