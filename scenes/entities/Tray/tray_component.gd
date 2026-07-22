extends Control
class_name TrayComponent

var collected_items: Array[FoodData] = []

@onready var zone_depot_foods: HBoxContainer = $TrayContainer/MarginContainer/ZoneDepotFoods
@onready var tray_container: NinePatchRect = $TrayContainer

@export var current_max_capacity: int = GameDataManager.current_max_capacity


func _ready() -> void:
	GameDataManager.tray_updated.connect(update_tray_visuals)
	update_tray_visuals()

func add_item(item: FoodData) -> bool:
	if GameDataManager.tray_items.size() < current_max_capacity:
		GameDataManager.tray_items.append(item)
		print("DEBUG : Succès ! Nouvel état du plateau : ", GameDataManager.tray_items.size(), "/", current_max_capacity)
		GameDataManager.tray_updated.emit()
		return true
	return false

func update_tray_visuals()-> void:
	# On spécifie la taille du tray dépendamment du nombre d'item max
	var tray_margin: int = 40
	tray_container.custom_minimum_size = Vector2(GameDataManager.item_target_size * current_max_capacity + tray_margin, GameDataManager.item_target_size + tray_margin)
	# On vide le conteneur
	for child: Node in zone_depot_foods.get_children():
		child.queue_free()
	
	# On parcourt la liste
	for i: int in range(GameDataManager.tray_items.size()):
		var item: FoodData = GameDataManager.tray_items[i]
		# création des éléments de tray (bouton pour qu'il puisse être cliquable/supprimable)
		var item_in_tray: TextureButton = TextureButton.new()
		item_in_tray.texture_normal = item.sprite
		# Modifie la taille de la texture pour s'assurer que ça entre dans le tray
		item_in_tray.custom_minimum_size = Vector2(GameDataManager.item_target_size, GameDataManager.item_target_size)
		item_in_tray.ignore_texture_size = true
		item_in_tray.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		item_in_tray.pivot_offset = item_in_tray.custom_minimum_size / 2

		# Appel la fonction lors du clic
		item_in_tray.pressed.connect(_on_item_in_tray_pressed.bind(i))
		
		zone_depot_foods.add_child(item_in_tray)

# Fonction appelée quand on clique sur un aliment dans le plateau
func _on_item_in_tray_pressed(index: int):
	if index < 0 or index >= GameDataManager.tray_items.size():
		return

	var button: TextureButton = zone_depot_foods.get_child(index)
	button.disabled = true # évite un double-clic pendant l'animation

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "modulate:a", 0.0, 0.2)
	tween.tween_property(button, "scale", Vector2.ZERO, 0.2)
	tween.chain().tween_callback(func():
		GameDataManager.tray_items.remove_at(index) # Supprime l'aliment du tray
		print(index, " est supprimé du tray")
		GameDataManager.tray_updated.emit()
	)
