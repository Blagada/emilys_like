extends Control
class_name DayResultsScreen

signal continue_pressed

@export var restaurant_name_label: Label
@export var level_number_label: Label
@export var earnings_label: RichTextLabel
@export var goal_status_label: RichTextLabel
@export var expert_status_label: RichTextLabel
@export var tip_label: RichTextLabel
@export var continue_button: Button


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)


func setup(level_data: LevelData, earnings: float, daily_goal: float, expert_goal: float, tip_earned: float) -> void:
	restaurant_name_label.text = "Restaurant %s" % level_data.restaurant.restaurant_name
	
	earnings_label.text = "Montant fait : %.0f$" % earnings

	if earnings >= daily_goal:
		level_number_label.text = "Jour %d atteint" % level_data.level_number
	else:
		level_number_label.text = "Jour %d manqué" % level_data.level_number
	
	goal_status_label.text = "Objectif (%.0f$)" % daily_goal

	if earnings >= expert_goal:
		expert_status_label.text = "Score expert atteint (%.0f$)" % expert_goal
	else:
		expert_status_label.text = "Score expert manqué (%.0f$)" % expert_goal

	var rounded_tip: float = snapped(tip_earned, 25.0)
	tip_label.text = "Pourboires gagnés : %.0f$" % rounded_tip

	visible = true


func _on_continue_pressed() -> void:
	continue_pressed.emit()
	visible = false
