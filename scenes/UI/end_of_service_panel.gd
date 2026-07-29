extends Control
class_name EndOfServicePanel


func _ready() -> void:
	visible = false


func show_panel() -> void:
	visible = true
	await get_tree().create_timer(3.0).timeout
	hide_panel()


func hide_panel() -> void:
	visible = false
