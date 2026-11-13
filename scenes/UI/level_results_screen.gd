extends Control
class_name LevelResultsScreen

@export var level_bar: LevelBar
@export var level_number_label: Label
@export var earnings_label: RichTextLabel
@export var goal_status_label: RichTextLabel
@export var expert_status_label: RichTextLabel
@export var tip_label: RichTextLabel


func _ready() -> void:
	visible = false
	level_bar.primary_pressed.connect(_on_primary_pressed)


func texts_setup(level_data: LevelData, earnings: float, daily_goal: float, expert_goal: float, tip_earned: float) -> void:
	var normal_reached: bool = earnings >= daily_goal
	var expert_reached: bool = earnings >= expert_goal
	var rounded_tip: float = snapped(tip_earned, 5.0)

	earnings_label.text = tr("EARNINGS_MADE") % CurrencyService.format(earnings)
	goal_status_label.text = tr("GOAL_STATUS") % CurrencyService.format(daily_goal, 0)
	level_number_label.text = tr("LEVEL_DAY") % level_data.level_number

	if normal_reached:
		level_number_label.text = tr("DAY_REACHED") % level_data.level_number
	else:
		level_number_label.text = tr("DAY_MISSED") % level_data.level_number

	if expert_reached:
		var final_tip: float = EarningsManager.apply_expert_tip_bonus(2.0)
		var rounded_final_tip: float = snapped(final_tip, 5.0)
		expert_status_label.text = tr("EXPERT_REACHED") % CurrencyService.format(expert_goal, 0)
		tip_label.text = tr("TIPS_DOUBLED") % [CurrencyService.format(rounded_tip, 0), CurrencyService.format(rounded_final_tip, 0)]
	else:
		expert_status_label.text = tr("EXPERT_MISSED") % CurrencyService.format(expert_goal, 0)
		tip_label.text = tr("TIPS_EARNED") % CurrencyService.format(rounded_tip, 0)

	

func setup(level_data: LevelData, earnings: float, daily_goal: float, expert_goal: float, tip_earned: float) -> void:
	texts_setup(level_data, earnings, daily_goal, expert_goal, tip_earned)
	visible = true

func _on_primary_pressed() -> void:
	visible = false
