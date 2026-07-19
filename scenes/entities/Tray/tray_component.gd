extends Control
class_name TrayComponent

var collected_items: Array[FoodData] = []

@onready var zone_depot_foods: GridContainer = $TrayContainer/ZoneDepotFoods

func _ready() -> void:
	GameDataManager.tray_updated.connect(update_tray_visuals)
	update_tray_visuals()

func add_item(item: FoodData) -> bool:
	if GameDataManager.tray_items.size() < GameDataManager.current_max_capacity:
		GameDataManager.tray_items.append(item)
		print("DEBUG : Succès ! Nouvel état du plateau : ", GameDataManager.tray_items.size(), "/", GameDataManager.current_max_capacity)
		GameDataManager.tray_updated.emit()
		return true
	return false

func update_tray_visuals()-> void:
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
		item_in_tray.custom_minimum_size = Vector2(50, 50)
		item_in_tray.ignore_texture_size = true
		item_in_tray.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		# Appel la fonction lors du clic
		item_in_tray.pressed.connect(_on_item_in_tray_pressed.bind(i))
		
		zone_depot_foods.add_child(item_in_tray)

# Fonction appelée quand on clique sur un aliment dans le plateau
func _on_item_in_tray_pressed(index: int):
	if index >= 0 and index < GameDataManager.tray_items.size():
		GameDataManager.tray_items.remove_at(index)
		print(index, " est supprimé du tray")
		GameDataManager.tray_updated.emit()
