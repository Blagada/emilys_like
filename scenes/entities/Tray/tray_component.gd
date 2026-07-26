extends Control
class_name TrayComponent

var collected_items: Array[FoodData] = []

@onready var zone_depot_foods: HBoxContainer = $TrayContainer/MarginContainer/ZoneDepotFoods
@onready var tray_container: NinePatchRect = $TrayContainer
@onready var player: Node = get_tree().get_first_node_in_group("Player")

@export var current_max_capacity: int = GameDataManager.current_max_capacity

const PENDING_MODULATE: Color = Color(1, 1, 1, 0.4)


func _ready() -> void:
	GameDataManager.tray_updated.connect(update_tray_visuals)
	GameDataManager.pending_updated.connect(update_tray_visuals)
	update_tray_visuals()


func add_item(item: FoodData) -> bool:
	if GameDataManager.tray_items.size() < current_max_capacity:
		GameDataManager.tray_items.append(item)
		print("DEBUG : Succès ! Nouvel état du plateau : ", GameDataManager.tray_items.size(), "/", current_max_capacity)
		GameDataManager.tray_updated.emit()
		return true
	return false


func update_tray_visuals() -> void:
	var tray_margin: int = 40
	tray_container.custom_minimum_size = Vector2(GameDataManager.item_target_size * current_max_capacity + tray_margin, GameDataManager.item_target_size + tray_margin)

	for child: Node in zone_depot_foods.get_children():
		child.queue_free()

	for i: int in range(GameDataManager.tray_items.size()):
		var item: FoodData = GameDataManager.tray_items[i]
		var button: TextureButton = _create_tray_button(item.sprite)
		button.pressed.connect(_on_item_in_tray_pressed.bind(i))
		zone_depot_foods.add_child(button)

	for entry: Dictionary in GameDataManager.pending_items:
		var food: FoodData = entry["food_data"]
		var button: TextureButton = _create_tray_button(food.sprite)
		button.modulate = PENDING_MODULATE
		button.pressed.connect(_on_pending_item_pressed.bind(entry["action_id"], button))
		zone_depot_foods.add_child(button)


func _create_tray_button(texture: Texture2D) -> TextureButton:
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.custom_minimum_size = Vector2(GameDataManager.item_target_size, GameDataManager.item_target_size)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.pivot_offset = button.custom_minimum_size / 2
	return button


func _on_item_in_tray_pressed(index: int) -> void:
	if index < 0 or index >= GameDataManager.tray_items.size():
		return

	var button: TextureButton = zone_depot_foods.get_child(index)
	button.disabled = true

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "modulate:a", 0.0, 0.2)
	tween.tween_property(button, "scale", Vector2.ZERO, 0.2)
	tween.chain().tween_callback(func():
		GameDataManager.tray_items.remove_at(index)
		print(index, " est supprimé du tray")
		GameDataManager.tray_updated.emit()
	)


func _on_pending_item_pressed(action_id: int, button: TextureButton) -> void:
	if not player:
		return

	if player.action_queue.cancel(action_id):
		GameDataManager.remove_pending_item(action_id)
	else:
		# Trop tard, déjà en préparation : on marque pour suppression une fois prêt
		GameDataManager.request_cancel_pending_item(action_id)
		button.disabled = true
		button.modulate.a = 0.15
