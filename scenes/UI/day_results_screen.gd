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


func setup(level_data: LevelData, earnings: float, daily_goal: float, expert_goal: float, tip_earned: float) -> void:
	var normal_reached: bool = earnings >= daily_goal
	var expert_reached: bool = earnings >= expert_goal
	var rounded_tip: float = snapped(tip_earned, 5.0)

	restaurant_name_label.text = "Restaurant %s" % level_data.restaurant.restaurant_name
	earnings_label.text = "Montant fait : %.2f$" % earnings
	goal_status_label.text = "Objectif (%.0f$)" % daily_goal

	if normal_reached:
		level_number_label.text = "Jour %d atteint" % level_data.level_number
	else:
		level_number_label.text = "Jour %d manqué" % level_data.level_number

	if expert_reached:
		var final_tip: float = EarningsManager.apply_expert_tip_bonus(2.0)
		var rounded_final_tip: float = snapped(final_tip, 5.0)
		expert_status_label.text = "Score expert atteint (%.0f$)" % expert_goal
		tip_label.text = "Pourboires gagnés : %.0f$ x 2 = %.0f$" % [rounded_tip, rounded_final_tip]
	else:
		expert_status_label.text = "Score expert manqué (%.0f$)" % expert_goal
		tip_label.text = "Pourboires gagnés : %.0f$" % rounded_tip

	visible = true


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()
	visible = false
