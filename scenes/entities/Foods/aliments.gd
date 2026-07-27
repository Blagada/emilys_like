extends Node
class_name FoodItem

@export var food_data: FoodData # Contient l'aliment à afficher

@onready var interaction_component: Interactable = $InteractionComponent
@onready var aliment_sprite: Sprite2D = $AlimentSprite
@onready var player: Player = get_tree().get_first_node_in_group("Player") as Player

signal food_clicked(item: FoodData) # Le signal envoie la ressource concernée

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


func _on_action_queued(action_id: int) -> void:
	TrayManager.add_pending_item(action_id, food_data)


func _on_player_arrived(action_id: int) -> void:
	await player.staff_component.start_task(GameEnums.StaffState.FOOD_PREP, food_data.preparation_time)

	var was_cancelled: bool = TrayManager.consume_pending_item(action_id)

	if not was_cancelled:
		food_clicked.emit(food_data)

	interaction_component.complete_action(action_id)


func _has_tray_space() -> bool:
	# Vérifie si le tray est plein, avec des préparations faite et des préparations en attente
	var occupied: int = TrayManager.tray_items.size() + TrayManager.pending_items.size()
	return occupied < TrayManager.current_max_capacity
