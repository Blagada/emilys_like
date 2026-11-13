extends Node
class_name FoodItem

# --- RÉFÉRENCES ET DONNÉES DE L'ALIMENT ---
@export var food_data: FoodData # Contient l'aliment à afficher[cite: 2]

@onready var interaction_component: Interactable = $InteractionComponent
@onready var aliment_sprite: Sprite2D = $AlimentSprite
@onready var player: Player = get_tree().get_first_node_in_group("Player") as Player

signal food_clicked(item: FoodData) # Le signal envoie la ressource concernée[cite: 2]


## Initialise l'élément alimentaire au lancement.
## Configure l'interaction, applique la texture de l'aliment sur le sprite et ajuste son échelle, puis connecte les signaux d'interaction.
func _ready() -> void:
	interaction_component.can_interact = _has_tray_space

	if food_data and aliment_sprite:
		aliment_sprite.texture = food_data.sprite
		var tex_size: Vector2 = aliment_sprite.texture.get_size()
		var target_size = Vector2(TrayManager.item_target_size, TrayManager.item_target_size)

		if tex_size.x > 0 and tex_size.y > 0:
			var scale_factor: float = min(target_size.x / tex_size.x, target_size.y / tex_size.y)
			aliment_sprite.scale = Vector2(scale_factor, scale_factor)

	if interaction_component:
		interaction_component.action_queued.connect(_on_action_queued)
		interaction_component.player_arrived.connect(_on_player_arrived)


## Callback déclenché lorsqu'une action est mise en file d'attente.
## Ajoute l'aliment aux éléments en attente dans le gestionnaire de plateau (TrayManager).
func _on_action_queued(action_id: int) -> void:
	TrayManager.add_pending_item(action_id, food_data)


## Callback déclenché lorsque le joueur arrive sur place pour effectuer l'action.
## Lance la tâche de préparation, vérifie si l'action n'a pas été annulée, émet le signal de clic et complète l'action.
func _on_player_arrived(action_id: int) -> void:
	await player.staff_component.start_task(GameEnums.StaffState.FOOD_PREP, food_data.preparation.preparation_time)

	var was_cancelled: bool = TrayManager.consume_pending_item(action_id)

	if not was_cancelled:
		food_clicked.emit(food_data)

	interaction_component.complete_action(action_id)


## Vérifie si le plateau (tray) dispose encore d'espace libre.
## Calcule l'espace occupé en tenant compte des éléments présents, en attente et réservés.
func _has_tray_space() -> bool:
	# Vérifie si le tray est plein, avec des préparations faite et des préparations en attente[cite: 2]
	var occupied: int = TrayManager.tray_items.size() + TrayManager.pending_items.size() - TrayManager.reserved_for_service
	return occupied < TrayManager.current_max_capacity
	

## Modifie la position globale du point d'interaction s'il existe.
func set_interaction_point(global_pos: Vector2) -> void:
	if interaction_component and interaction_component.has_node("InteractionPoint"):
		interaction_component.get_node("InteractionPoint").global_position = global_pos
