extends Resource
class_name CustomerVisual

@export_group("Identité")
@export var name: String
@export var visual_scene: PackedScene

@export_group("Restrictions de commande")
@export var required_tags: Array[GameEnums.FoodTag] = []
@export var forbidden_tags: Array[GameEnums.FoodTag] = []
