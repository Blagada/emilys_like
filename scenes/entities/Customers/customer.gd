extends CharacterBody2D
class_name Customer

@onready var visual_customer: Node2D = $VisualCustomer
@onready var movement_component: MovementComponent = $MovementComponent
@onready var collision_customer: CollisionShape2D = $CollisionCustomer

signal state_changed(new_state, target_pos)

var current_order: FoodData
var customer_data: CustomerData

func _physics_process(_delta):
	velocity = movement_component.get_velocity_for_movement()
	
	if velocity != Vector2.ZERO:
		# les animations seront géré par skin (dans leur scène respective)
		move_and_slide()


# On ne définit plus juste un 'client' (data), mais on reçoit les deux
func setup(visual: CustomerVisual, data: CustomerData):
	# Appliquer les données (Comportement)
	apply_data(data)
	
	# Appliquer le visuel
	# On nettoie le conteneur au cas où
	for child in visual_customer.get_children():
		child.queue_free()
		
	# On instancie le skin et on l'ajoute au conteneur
	var skin = visual.visual_scene.instantiate()
	visual_customer.add_child(skin)
	# Si le skin a bien une fonction 'on_state_changed', on la connecte
	if skin.has_method("on_state_changed"):
		state_changed.connect(skin.on_state_changed)


func apply_data(new_data: CustomerData):
	# Applique les propriétés (vitesse, etc.)
	customer_data = new_data
	movement_component.speed = new_data.speed
	print("Nouveau client de type : ", new_data.group_type)

func change_state(new_state, target_pos = Vector2.ZERO):
	state_changed.emit(new_state, target_pos)


func move_to_table(table_marker: Marker2D, table_position: Vector2):
	var table_pos = table_position
	# Lance le mouvement
	change_state(GameEnums.CustomerState.MOVING) # change l'état du client pour Marcher
	movement_component.set_target(table_marker.global_position)
	await movement_component.destination_reached # attend que le client atteinde la destination
	
	change_state(GameEnums.CustomerState.SITTING, table_pos) # Change l'état pour Assis + envoie position de la table
	# Désactive la collision
	collision_customer.set_deferred("disabled", true)
	
	# Création d'une animation douce (0.3 secondes)
	var tween = create_tween()
	tween.tween_property(self, "global_position", table_marker.global_position, 0.3)
	
	print("Client assis et collision désactivée.")


func set_order(food: FoodData):
	current_order = food
