extends Node2D
class_name OrderBubbleComponent

# --- RÉFÉRENCES ET SCÈNES ---
@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

var _bubble: Node = null


## Affiche la liste des commandes dans la bulle. 
## Si la liste est vide, masque la bulle ; sinon, s'assure qu'elle existe et y transmet les commandes[cite: 4].
func show_orders(orders: Array[FoodData]) -> void:
	if orders.is_empty():
		hide_bubble()
		return
	_ensure_instance()
	_bubble.show_orders(orders)


## Affiche des points de suspension ("...") dans la bulle pour indiquer que le personnage réfléchit[cite: 4].
func show_thinking() -> void:
	_ensure_instance()
	_bubble.show_text("...")


## Affiche un point d'exclamation ("!") dans la bulle pour indiquer un état particulier ou urgent (ex: table sale)[cite: 4].
func show_dirty() -> void:
	_ensure_instance()
	_bubble.show_text("!")


## Masque et détruit l'instance de la bulle si elle est actuellement active[cite: 4].
func hide_bubble() -> void:
	if _bubble:
		_bubble.queue_free()
		_bubble = null


## Met à jour l'icône de patience affichée sur la bulle en fonction de l'état actuel[cite: 4].
func update_patience_icon(state: GameEnums.PatienceState) -> void:
	if _bubble:
		_bubble.set_patience_icon(state)


## Fonction interne pour s'assurer qu'une instance de la bulle existe.
## Si ce n'est pas le cas, elle l'instancie et l'ajoute en tant qu'enfant au point d'ancrage (`order_bubble_anchor`)[cite: 4].
func _ensure_instance() -> void:
	if _bubble == null:
		_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(_bubble)
