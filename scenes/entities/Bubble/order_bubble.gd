extends MarginContainer
class_name OrderBubble

# --- RÉFÉRENCES DES ÉLÉMENTS DE L'UI ---
@export var waiting_label: Label
@export var status_label: Label
@export var orders_grid: GridContainer

# --- GROUPES ET TEXTURES DE PATIENCE ---
@export_group("Patience")
@export var patience_indicator: TextureRect
@export var happy_texture: Texture2D
@export var impatient_texture: Texture2D
@export var angry_texture: Texture2D

const PATIENCE_TEXTURES: Dictionary = {}  # rempli en _ready() une fois les exports en main[cite: 3]


## Affiche un texte de statut spécifique (ex: "...", "$", montant de la facture) 
## tout en masquant la grille de commandes et le libellé d'attente.
func show_text(text: String) -> void:
	orders_grid.visible = false
	status_label.text = text
	status_label.visible = true
	waiting_label.visible = false


## Affiche un texte d'attente (ex: taille du groupe de clients) 
## tout en masquant le statut et la grille de commandes.
func show_waiting_text(text: String) -> void:
	orders_grid.visible = false
	waiting_label.text = text
	waiting_label.visible = true
	status_label.visible = false


## Affiche la liste des commandes sous forme d'icônes d'aliments dans la grille.
## Nettoie d'abord les anciens éléments présents dans la grille, puis génère dynamiquement de nouvelles icônes.
func show_orders(orders: Array[FoodData]) -> void:
	status_label.visible = false
	waiting_label.visible = false
	orders_grid.visible = true

	for child: Node in orders_grid.get_children():
		child.queue_free()

	for order: FoodData in orders:
		var order_icon: TextureRect = TextureRect.new()
		order_icon.texture = order.sprite
		order_icon.custom_minimum_size = Vector2(TrayManager.item_target_size, TrayManager.item_target_size)
		order_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		order_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		order_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		order_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		orders_grid.add_child(order_icon)


## Met à jour l'indicateur visuel de patience de la bulle selon l'état actuel du client.
## Masque l'indicateur s'il est heureux, ou affiche la texture correspondante s'il est impatient ou en colère.
func set_patience_icon(state: GameEnums.PatienceState) -> void:
	match state:
		GameEnums.PatienceState.HAPPY:
			patience_indicator.visible = false
			#patience_indicator.texture = happy_texture
		GameEnums.PatienceState.IMPATIENT:
			patience_indicator.visible = true
			patience_indicator.texture = impatient_texture
		GameEnums.PatienceState.ANGRY:
			patience_indicator.visible = true
			patience_indicator.texture = angry_texture
