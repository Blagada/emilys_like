extends CharacterBody2D
class_name Customer

@onready var visual_customer: Node2D = $VisualCustomer
@onready var movement_component: MovementComponent = $MovementComponent
@onready var collision_customer: CollisionShape2D = $CollisionCustomer

@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

var order_bubble: Node = null
signal state_changed(new_state: GameEnums.CustomerState, target_pos: Vector2)

var current_order: FoodData
var customer_data: CustomerData
var current_state: GameEnums.CustomerState

func _physics_process(_delta: float) -> void:
	velocity = movement_component.get_velocity_for_movement()
	
	if velocity != Vector2.ZERO:
		# les animations seront géré par skin (dans leur scène respective)
		move_and_slide()


# On ne définit plus juste un 'client' (data), mais on reçoit les deux
func setup(visual: CustomerVisual, data: CustomerData) -> void:
	# Appliquer les données (Comportement)
	apply_data(data)
	
	# Nettoyage et instanciation du skin
	for child: Node in visual_customer.get_children():
		child.queue_free()
		
	# On instancie le skin et on l'ajoute au conteneur
	var skin: Node = visual.visual_scene.instantiate()
	visual_customer.add_child(skin)
	# Si le skin a bien une fonction 'on_state_changed', on la connecte
	if skin.has_method("on_state_changed"):
		state_changed.connect(skin.on_state_changed)


func apply_data(new_data: CustomerData) -> void:
	# TODO : Applique les propriétés (vitesse, etc.). Assigner les autres paramètres
	customer_data = new_data
	movement_component.speed = new_data.speed
	print("Nouveau client de type : ", new_data.group_type)


func change_state(new_state: GameEnums.CustomerState, target_pos: Vector2 = Vector2.ZERO) -> void:
	current_state = new_state

	if new_state == GameEnums.CustomerState.PAYING:
		_ensure_bubble_instance()
		order_bubble.show_text("$")
	elif order_bubble:
		order_bubble.queue_free()
		order_bubble = null

	state_changed.emit(new_state, target_pos)


func show_bill_amount(amount: float) -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("%.2f$" % amount)


func _ensure_bubble_instance() -> void:
	if order_bubble == null:
		order_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(order_bubble)


func set_order(food: FoodData)-> void:
	current_order = food
	
	
func move_to_table(table_marker: Marker2D, table_position: Vector2) -> void:
	# Lancement du mouvement vers la table
	change_state(GameEnums.CustomerState.MOVING) # change l'état du client pour Marcher
	movement_component.set_target(table_marker.global_position)
	await movement_component.destination_reached # attend que le client atteinde la destination
	
	change_state(GameEnums.CustomerState.SITTING, table_position) # Change l'état pour Assis + envoie position de la table
	# Désactivation sécurisée de la collision
	collision_customer.set_deferred("disabled", true)
	
	# Création d'une animation douce (0.3 secondes)
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", table_marker.global_position, 0.3)
	
	print("Client assis et collision désactivée.")


func move_to(target_marker: Marker2D, state: GameEnums.CustomerState = GameEnums.CustomerState.MOVING) -> void:
	change_state(state, target_marker.global_position)
	collision_customer.set_deferred("disabled", false)
	movement_component.set_target(target_marker.global_position)
	await movement_component.destination_reached
