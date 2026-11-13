extends PanelContainer
class_name RestaurantPanel

@export var restaurant_name_label: RichTextLabel
@export var day_cycle: DayCycleComponent


func show_restaurant_name(restaurant_name: String) -> void:
	visible = true
	texts_setup(restaurant_name)


func hide_restaurant_name() -> void:
	visible = false


func texts_setup(restaurant_name: String) -> void:
	restaurant_name_label.text = tr("RESTAURANT_TITLE") % tr(restaurant_name)
