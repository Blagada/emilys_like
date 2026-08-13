extends Node2D
class_name OrderBubbleComponent

@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

var _bubble: Node = null


func show_orders(orders: Array[FoodData]) -> void:
	if orders.is_empty():
		hide_bubble()
		return
	_ensure_instance()
	_bubble.show_orders(orders)


func show_thinking() -> void:
	_ensure_instance()
	_bubble.show_text("...")


func show_dirty() -> void:
	_ensure_instance()
	_bubble.show_text("!")


func hide_bubble() -> void:
	if _bubble:
		_bubble.queue_free()
		_bubble = null


func update_patience_icon(state: GameEnums.PatienceState) -> void:
	if _bubble:
		_bubble.set_patience_icon(state)


func _ensure_instance() -> void:
	if _bubble == null:
		_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(_bubble)
