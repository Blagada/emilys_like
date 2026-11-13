extends Control
class_name HomeScreen

@export var restaurants: Array[RestaurantData]
@export var restaurant_panel: RestaurantPanel
@export var levels_container : GridContainer
@export var desc_resto_label: RichTextLabel

const LEVEL_BUTTON: PackedScene = preload("res://scenes/UI/level_button.tscn")

func _ready() -> void:
	# TODO : En attendant la sauvegarde, resto par défaut : 0
	_setup_resto_info(0)


func _setup_resto_info(index_resto: int) -> void:
	# Envoie des infos du resto en cours
	var resto_name = restaurants.get(index_resto).restaurant_name
	restaurant_panel.show_restaurant_name(resto_name)
	desc_resto_label.text = "%s" % tr(restaurants.get(index_resto).restaurant_desc)
	
	
	# Réinitialise les niveaux lorsque setup est appelé
	for child in levels_container.get_children():
		child.queue_free()

	# Pour chaque niveau existant dans le resto
	for level: LevelData in restaurants.get(index_resto).levels:
		# Ajoute un level button
		var button: LevelButton = LEVEL_BUTTON.instantiate()
		levels_container.add_child(button)
		# Envoie les infos pour afficher le texte et l'état du bouton
		button.setup(level)
		# Se connecte au signal du clic
		button.level_selected.connect(_on_level_selected)


func _on_level_selected(level: LevelData) -> void:
	get_tree().change_scene_to_file(level.level_path)
