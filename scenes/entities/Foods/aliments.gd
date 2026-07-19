extends Node
class_name FoodItem

@export var food_data: FoodData # Contient l'aliment à afficher
@export var target_size: Vector2 = Vector2(64, 64) # La taille que tu veux pour tous

@onready var interaction_component: Interactable = $InteractionComponent
@onready var aliment_sprite: Sprite2D = $AlimentSprite

signal food_clicked(item: FoodData) # Le signal envoie la ressource concernée

func _ready() -> void:
	if food_data and aliment_sprite:
		aliment_sprite.texture = food_data.sprite
		var tex_size: Vector2 = aliment_sprite.texture.get_size()
		# Protection contre la division par zéro
		if tex_size.x > 0 and tex_size.y > 0:
			aliment_sprite.scale = target_size / tex_size

	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)


func _on_player_arrived() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player") as Player
	
	if player:
		print("Préparation lancée...")
		player.is_busy = true # tant que la préparation n'est pas terminé
		await get_tree().create_timer(food_data.preparation_time).timeout

		player.is_busy = false # préparation terminée
		food_clicked.emit(food_data)
