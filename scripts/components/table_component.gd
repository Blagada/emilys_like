extends Node
class_name TableComponent

# À besoin du Node ChairPositions avec des Marker2D pour gérer la position des chaises.
@onready var all_chair_positions: Array[Node] = chair_positions.get_children()
@export var chair_positions: Node2D
@export var interaction_component: Interactable
@export var current_state: GameEnums.TableState = GameEnums.TableState.UNOCCUPIED_AND_CLEAN # Par défaut, toutes les chaises sont libre et propre
@export var order_component: OrderComponent
@export var cleaning_duration: float = 3.0

var occupied_seats: Array[Marker2D] = [] # Liste pour garder en mémoire quels sièges sont pris
var is_dirty: bool = false

func _ready() -> void:
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)


func _on_player_arrived(action_id: int)-> void:
	var player: Node = get_tree().get_first_node_in_group("Player")

	var can_clean: bool = current_state == GameEnums.TableState.WAITING_FOR_CLEANING \
		or (current_state == GameEnums.TableState.WAITING_FOR_PAYMENT and is_dirty)

	if can_clean:
		_start_cleaning(player, action_id)
		return

	order_component.serve_food()
	interaction_component.complete_action(action_id)


func _start_cleaning(player: Node, action_id: int) -> void:
	if not player or not player.has_node("StaffComponent"):
		return

	await player.staff_component.start_task(GameEnums.StaffState.CLEANING, cleaning_duration)

	is_dirty = false
	order_component.hide_order_bubble()

	if current_state == GameEnums.TableState.WAITING_FOR_CLEANING:
		current_state = GameEnums.TableState.UNOCCUPIED_AND_CLEAN

	interaction_component.complete_action(action_id)


# Retourne vrai si la table n'est pas occupé et a assez de chaises libres
func can_accommodate_group(group_size: int) -> bool:
	# 1. Vérifie si la table est déjà occupée
	if current_state != GameEnums.TableState.UNOCCUPIED_AND_CLEAN:
		return false
	
	# 2. Vérifie si la table a assez de chaises pour le groupe
	if all_chair_positions.size() < group_size:
		return false
		
	# 3. La table est libre et assez grande
	return true


func reserve_seats(group_size: int) -> Array[Marker2D]:
	var reserved: Array[Marker2D] = []
	
	# 1. On garde TA validation complète des états (sécurité)
	if current_state == GameEnums.TableState.AWAITING_SERVICE or \
	   current_state == GameEnums.TableState.IN_MEAL:
		return []
	
	# 2. On boucle sur TOUTES les chaises disponibles
	# Au lieu de 'range(group_size)', on cherche celles qui ne sont pas dans 'occupied_seats'
	for seat: Marker2D in all_chair_positions:
		if not occupied_seats.has(seat):
			occupied_seats.append(seat) # On marque le siège comme pris
			reserved.append(seat)       # On l'ajoute à la liste pour le LevelComponent
			
			# Si on a assez de sièges, on arrête de chercher
			if reserved.size() == group_size:
				break
	
	# 3. Sécurité : si on n'a pas trouvé assez de places, on annule tout
	if reserved.size() < group_size:
		print("Erreur : pas assez de places libres trouvées")
		return []

	# 4. On met à jour l'état comme tu le faisais
	current_state = GameEnums.TableState.AWAITING_SERVICE

	# On renvoie bien les Marker2D, comme avant
	return reserved
