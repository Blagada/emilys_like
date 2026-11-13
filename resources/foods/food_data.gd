extends Resource
class_name FoodData

@export_group("Identité")
@export var name: String = "Aliment"
@export var sprite: Texture2D  # image de l'aliment (tray, bulles)
@export var container: FoodContainerData # récipient sur le comptoir (peut être vide)
@export var price: int = 10
var type: GameEnums.FoodType:
	get:
		return preparation.type

@export_group("Étiquettes")
@export var tags: Array[GameEnums.FoodTag] = []

@export_group("Préparation")
@export var preparation: FoodPreparationData

func has_tag(tag: GameEnums.FoodTag) -> bool:
	# Vérifie si le tableau de tags de l'aliment contient ce tag
	return tags.has(tag)
