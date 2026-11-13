extends PanelContainer
class_name LevelControl

@export var day_cycle: DayCycleComponent
@export var level_title: RichTextLabel

func _ready() -> void:
	day_cycle.day_completed.connect(_on_day_completed)

func setup(level_data: LevelData, restaurant_data: RestaurantData, level_control_open: bool) -> void:
	texts_setup(level_data, restaurant_data)
	visible = level_control_open

func texts_setup(level_data: LevelData, restaurant_data: RestaurantData) -> void:
	level_title.text = tr("LEVEL_CONTROL_TITLE") % [restaurant_data.restaurant_name, level_data.level_number]

func _on_day_completed() -> void:
	visible = false
