extends MarginContainer
class_name OrderBubble

@export var status_label: Label
@export var orders_grid: GridContainer

@export_group("Patience")
@export var patience_indicator: TextureRect
@export var happy_texture: Texture2D
@export var impatient_texture: Texture2D
@export var angry_texture: Texture2D

const PATIENCE_TEXTURES: Dictionary = {}  # rempli en _ready() une fois les exports en main

func show_text(text: String) -> void:
	orders_grid.visible = false
	status_label.text = text
	status_label.visible = true


func show_orders(orders: Array[FoodData]) -> void:
	status_label.visible = false
	orders_grid.visible = true

	for child: Node in orders_grid.get_children():
		child.queue_free()

	for order: FoodData in orders:
		var order_icon: TextureRect = TextureRect.new()
		order_icon.texture = order.sprite
		order_icon.custom_minimum_size = Vector2(TrayManager.item_target_size, TrayManager.item_target_size)
		order_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		order_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		order_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		order_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		orders_grid.add_child(order_icon)


func set_patience_icon(state: GameEnums.PatienceState) -> void:
	match state:
		GameEnums.PatienceState.HAPPY:
			patience_indicator.visible = false
			#patience_indicator.texture = happy_texture
		GameEnums.PatienceState.IMPATIENT:
			patience_indicator.visible = true
			patience_indicator.texture = impatient_texture
		GameEnums.PatienceState.ANGRY:
			patience_indicator.visible = true
			patience_indicator.texture = angry_texture
