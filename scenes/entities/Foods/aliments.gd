extends Node

@export var food_data: FoodData # Contient l'aliment à afficher
@export var target_size = Vector2(64, 64) # La taille que tu veux pour tous

@onready var interaction_component: Interactable = $InteractionComponent
@onready var aliment_sprite: Sprite2D = $AlimentSprite

signal food_clicked(item: FoodData) # Le signal envoie la ressource concernée

func _ready() -> void:
	if food_data:
		aliment_sprite.texture = food_data.sprite
		var tex_size = aliment_sprite.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			aliment_sprite.scale = target_size / tex_size

	interaction_component.player_arrived.connect(_on_player_arrived)


func _on_player_arrived():
	print("Préparation lancée...")
	await get_tree().create_timer(food_data.preparation_time).timeout

	var player = get_tree().get_first_node_in_group("Player")
	player.is_busy = false
	food_clicked.emit(food_data)
