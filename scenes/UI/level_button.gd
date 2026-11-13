extends Button
class_name LevelButton

signal level_selected(level: LevelData)


func setup(level: LevelData) -> void:
	text = "%s" % level.level_number


func _on_level_button_pressed() -> void:
	level_selected.emit()
