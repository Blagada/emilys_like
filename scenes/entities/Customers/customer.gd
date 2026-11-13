extends CharacterBody2D
class_name Customer

# --- RÉFÉRENCES ET COMPOSANTS DU CLIENT ---
@export var collision_customer: CollisionShape2D
@export var visual_customer: Node2D
@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

@export_group("Scripts")
@export var movement_component: MovementComponent
@export var patience_component: PatienceComponent
@export var bonus_star: BonusStarComponent

# --- VARIABLES D'ÉTAT DU CLIENT ---
var order_bubble: Node = null
signal state_changed(new_state: GameEnums.CustomerState, target_pos: Vector2)

var current_order: FoodData
var customer_data: CustomerData
var customer_visual: CustomerVisual
var current_state: GameEnums.CustomerState


## Initialise le client lors de son apparition dans la scène.
## Connecte notamment le signal de changement de patience du composant dédié.
func _ready() -> void:
	patience_component.patience_state_changed.connect(_on_patience_state_changed)


## Gère le déplacement physique du client à chaque frame physique.
## Calcule la vitesse via le MovementComponent et déplace le client s'il bouge.
func _physics_process(_delta: float) -> void:
	velocity = movement_component.get_velocity_for_movement()

	if velocity != Vector2.ZERO:
		move_and_slide()


## Callback appelé lorsque le niveau de patience du client change.
## Met à jour l'icône de patience sur la bulle du client si elle est affichée.
func _on_patience_state_changed(new_state: GameEnums.PatienceState) -> void:
	if order_bubble:
		order_bubble.set_patience_icon(new_state)


## Configure l'apparence visuelle et les données de base du client.
## Remplace tout visuel existant par le nouveau skin fourni et connecte le signal d'état.
func setup(visual: CustomerVisual, data: CustomerData) -> void:
	apply_data(data, visual)

	for child: Node in visual_customer.get_children():
		child.queue_free()

	var skin: Node = visual.visual_scene.instantiate()
	visual_customer.add_child(skin)
	if skin.has_method("on_state_changed"):
		state_changed.connect(skin.on_state_changed)


## Applique les données spécifiques au client (par exemple la vitesse de déplacement).
func apply_data(new_data: CustomerData, new_visual: CustomerVisual) -> void:
	customer_data = new_data
	customer_visual = new_visual
	movement_component.speed = new_data.speed


## Modifie l'état actuel du client et émet le signal `state_changed` pour avertir les autres systèmes.
func change_state(new_state: GameEnums.CustomerState, target_pos: Vector2 = Vector2.ZERO) -> void:
	current_state = new_state
	state_changed.emit(new_state, target_pos)


## Affiche la bulle de commande du client avec la nourriture demandée.
func show_order_bubble(food: FoodData) -> void:
	_ensure_bubble_instance()
	var typed_array: Array[FoodData] = [food]
	order_bubble.show_orders(typed_array)


## Affiche des points de suspension ("...") dans la bulle (le client réfléchit à sa commande).
func show_thinking() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("...")


## Affiche le symbole de paiement ("$") dans la bulle quand le client attend de payer.
func show_waiting_payment_bubble() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text(tr("CURRENCY_SYMBOL"))


## Affiche le montant de la facture dans la bulle. Le format dépend de la langue.
func show_bill_amount(amount: float) -> void:
	_ensure_bubble_instance()
	order_bubble.show_text(CurrencyService.format(amount))


## Affiche le texte demandant une table pour un certain nombre de personnes.
func show_group_size(size: int) -> void:
	_ensure_bubble_instance()
	order_bubble.show_waiting_text(tr("TABLE_FOR") % size)


## Masque et détruit la bulle d'information/commande actuellement affichée.
func hide_bubble() -> void:
	if order_bubble:
		order_bubble.queue_free()
		order_bubble = null


## Fonction interne pour s'assurer que l'instance de la bulle d'information existe.
## Si elle n'existe pas encore, elle est instanciée et ajoutée sous `order_bubble_anchor`.
func _ensure_bubble_instance() -> void:
	if order_bubble == null:
		order_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(order_bubble)


## Enregistre la commande courante du client.
func set_order(food: FoodData)-> void:
	current_order = food


## Déplace le client jusqu'à une table, l'assoit (désactive sa collision) et l'aligne doucement avec un Tween.
func move_to_table(table_marker: Marker2D, table_position: Vector2) -> void:
	change_state(GameEnums.CustomerState.MOVING)
	movement_component.set_target(table_marker.global_position)
	await movement_component.destination_reached

	change_state(GameEnums.CustomerState.SITTING, table_position)
	collision_customer.set_deferred("disabled", true)

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", table_marker.global_position, 0.3)


## Déplace le client vers n'importe quel repère (Marker2D) en réactivant sa collision et en mettant à jour son état.
func move_to(target_marker: Marker2D, state: GameEnums.CustomerState = GameEnums.CustomerState.MOVING) -> void:
	change_state(state, target_marker.global_position)
	collision_customer.set_deferred("disabled", false)
	movement_component.set_target(target_marker.global_position)
	await movement_component.destination_reached


## Joue l'animation ou l'effet d'étoile bonus si le composant `bonus_star` est présent.
func show_bonus_star() -> void:
	if bonus_star:
		bonus_star.play()
