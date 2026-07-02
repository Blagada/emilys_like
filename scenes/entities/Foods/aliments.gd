extends Node

@export var food_data: FoodData # Contient l'aliment à afficher
@export var target_size = Vector2(64, 64) # La taille que tu veux pour tous

@onready var interaction_component: Interactable = $InteractionComponent
@onready var aliment_sprite: Sprite2D = $AlimentSprite

signal food_clicked(item: FoodData) # Le signal envoie la ressource concernée

func _ready() -> void:
	if food_data:
		aliment_sprite.texture = food_data.sprite


func _on_interaction_component_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var player = get_tree().get_first_node_in_group("Player")
		# Vérification si le joueur n'est présent là ou est déjà en train de faire quelque chose
		if player == null or player.is_busy:
			return
			
		# Début de la séquence
		player.is_busy = true # <-- ON VERROUILLE

		# Déplacement
		if player.has_method("set_movement_target"):
			player.set_movement_target(interaction_component.interaction_point.global_position)
			# Attente du signal de movement component
			await player.movement_component.destination_reached
			
			# Préparation
			print("Préparation lancée...")
			await get_tree().create_timer(food_data.preparation_time).timeout
			
			# 4. Succès
			player.is_busy = false # <-- ON DÉVERROUILLE
			food_clicked.emit(food_data)
