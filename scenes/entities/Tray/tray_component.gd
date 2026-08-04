extends Control
class_name TrayComponent

# --- VARIABLES D'ÉTAT ---
var collected_items: Array[FoodData] = []

# --- EXPORTS & NŒUDS INTERNES ---
@onready var zone_depot_foods: HBoxContainer = $TrayContainer/MarginContainer/ZoneDepotFoods
@onready var tray_container: NinePatchRect = $TrayContainer
@onready var player: Node = get_tree().get_first_node_in_group("Player")

# Couleur semi-transparente appliquée aux éléments en attente de préparation (pending)
const PENDING_MODULATE: Color = Color(1, 1, 1, 0.4)


# --- INITIALISATION ---
func _ready() -> void:
	# Connexion aux signaux globaux du gestionnaire de plateau pour rafraîchir l'affichage automatiquement
	TrayManager.tray_updated.connect(update_tray_visuals)
	TrayManager.pending_updated.connect(update_tray_visuals)
	update_tray_visuals()


# --- AJOUT D'UN ITEM SUR LE PLATEAU ---
func add_item(item: FoodData) -> bool:
	# Vérifie si le plateau n'a pas atteint sa capacité maximale avant d'ajouter l'aliment
	if TrayManager.tray_items.size() < TrayManager.current_max_capacity:
		TrayManager.tray_items.append(item)
		TrayManager.tray_updated.emit()
		return true
	return false


# --- MISE À JOUR VISUELLE DU PLATEAU ---
# Recrée dynamiquement les boutons d'aliments (physiques et en attente) dans le conteneur horizontal
func update_tray_visuals() -> void:
	var tray_margin: int = 40
	var slots_used: int = 0
	
	# Ajuste la taille minimale du conteneur du plateau en fonction de la capacité maximale autorisée
	tray_container.custom_minimum_size = Vector2(TrayManager.item_target_size * TrayManager.current_max_capacity + tray_margin, TrayManager.item_target_size + tray_margin)

	# Nettoie d'abord tous les anciens visuels présents pour éviter les doublons
	for child: Node in zone_depot_foods.get_children():
		child.queue_free()

	# 1. Affiche les items physiques actuellement posés sur le plateau
	for i: int in range(TrayManager.tray_items.size()):
		if slots_used >= TrayManager.current_max_capacity:
			break
		else:
			var item: FoodData = TrayManager.tray_items[i]
			var button: TextureButton = _create_tray_button(item.sprite)
			button.pressed.connect(_on_item_in_tray_pressed.bind(i))
			zone_depot_foods.add_child(button)
			slots_used += 1

	# 2. Affiche les items en cours de préparation (pending) dans la même zone
	for entry: Dictionary in TrayManager.pending_items:
		if slots_used >= TrayManager.current_max_capacity:
			break
		else:
			var food: FoodData = entry["food_data"]
			var button: TextureButton = _create_tray_button(food.sprite)
			button.modulate = PENDING_MODULATE # Applique une transparence pour les différencier des vrais items
			button.pressed.connect(_on_pending_item_pressed.bind(entry["action_id"], button))
			zone_depot_foods.add_child(button)
			slots_used += 1


# --- CRÉATION D'UN BOUTON D'ALIMENT ---
# Fonction utilitaire pour instancier et configurer les propriétés visuelles de base d'un bouton d'item
func _create_tray_button(texture: Texture2D) -> TextureButton:
	var button: TextureButton = TextureButton.new()
	button.texture_normal = texture
	button.custom_minimum_size = Vector2(TrayManager.item_target_size, TrayManager.item_target_size)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.pivot_offset = button.custom_minimum_size / 2
	return button


# --- GESTION DU CLIC SUR UN ITEM DU PLATEAU ---
# Déclenche l'animation de suppression et retire l'aliment du plateau lorsqu'on clique dessus
func _on_item_in_tray_pressed(index: int) -> void:
	if index < 0 or index >= TrayManager.tray_items.size():
		return

	var button: TextureButton = zone_depot_foods.get_child(index)
	button.disabled = true

	# Animation de fondu et de rétrécissement avant la suppression réelle
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "modulate:a", 0.0, 0.2)
	tween.tween_property(button, "scale", Vector2.ZERO, 0.2)
	tween.chain().tween_callback(func():
		TrayManager.tray_items.remove_at(index)
		print(index, " est supprimé du tray")
		TrayManager.tray_updated.emit()
	)


# --- GESTION DU CLIC SUR UN ITEM EN ATTENTE (PENDING) ---
# Permet d'annuler ou de marquer pour annulation un plat qui est en cours de préparation
func _on_pending_item_pressed(action_id: int, button: TextureButton) -> void:
	if not player:
		return

	# Si l'action peut être annulée immédiatement dans la file du joueur, on la retire des pending
	if player.action_queue.cancel(action_id):
		TrayManager.remove_pending_item(action_id)
	else:
		# Trop tard, le plat est déjà en préparation : on le marque pour suppression dès qu'il sera prêt
		TrayManager.request_cancel_pending_item(action_id)
		button.disabled = true
		button.modulate.a = 0.15
