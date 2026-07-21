extends MarginContainer
class_name OrderBubble

@export var orders_grid: GridContainer
@export var thinking_label: Label
@export var payment_label: Label


func set_orders(orders: Array[FoodData]) -> void:
	thinking_label.visible = false
	payment_label.visible = false
	orders_grid.visible = true

	for child: Node in orders_grid.get_children():
		child.queue_free()

	for order: FoodData in orders:
		var order_icon: TextureRect = TextureRect.new()
		order_icon.texture = order.sprite
		order_icon.custom_minimum_size = Vector2(GameDataManager.item_target_size, GameDataManager.item_target_size)
		order_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		order_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		order_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		order_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		orders_grid.add_child(order_icon)


func show_thinking() -> void:
	orders_grid.visible = false
	payment_label.visible = false
	thinking_label.visible = true


func show_payment() -> void:
	orders_grid.visible = false
	thinking_label.visible = false
	payment_label.visible = true
