extends Control
class_name IntersectionPanel

@export var label_panel: Label

func _ready() -> void:
	visible = false


func show_timing_panel() -> void:
	label_panel.text = "END_SERVICE"
	show_panel()
	await get_tree().create_timer(4.0, false).timeout
	hide_panel()

func show_paused_panel() -> void:
	label_panel.text = "PAUSED"
	show_panel()

func show_panel() -> void:
	visible = true


func hide_panel() -> void:
	visible = false
