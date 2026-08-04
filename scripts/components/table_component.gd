extends Node
class_name TableComponent

# --- EXPORTS & CONFIGURATIONS ---
@export var order_component: OrderComponent
@export var interaction_component: Interactable
@export var chair_positions: Node2D
@export var table_sprite_node: Sprite2D
@export var custom_table_texture: AtlasTexture
@export var custom_chair_texture: AtlasTexture

@export var current_state: GameEnums.TableState = GameEnums.TableState.UNOCCUPIED_AND_CLEAN # Par défaut, toutes les chaises sont libres et propres

@export var cleaning_duration: float = 3.0
@export var serving_delay: float = 0.5

# --- VARIABLES D'ÉTAT & RÉFÉRENCES ---
# À besoin du Node ChairPositions avec des Marker2D pour gérer la position des chaises.
@onready var all_chair_positions: Array[Node] = chair_positions.get_children() # Liste de tous les nœuds de chaises enfants

var occupied_seats: Array[Marker2D] = [] # Liste pour garder en mémoire quels sièges sont pris
var _reserved_by_action: Dictionary = {} # Liste pour garder en mémoire des actions réservées (ex: action_id -> nombre d'items)
var is_dirty: bool = false               # Indique si la table est sale et nécessite un nettoyage


# --- INITIALISATION DE LA TABLE ---
func _ready() -> void:
	# Connexion des signaux liés aux interactions du joueur avec la table
	if interaction_component:
		interaction_component.player_arrived.connect(_on_player_arrived)
		interaction_component.action_queued.connect(_on_action_queued)
	
	# Applique la texture personnalisée de la table si elle est définie
	if custom_table_texture and table_sprite_node:
		table_sprite_node.texture = custom_table_texture
	
	# Applique la texture à toutes les chaises automatiquement au lancement
	_apply_texture_to_chairs()


# --- APPLICATION AUTOMATIQUE DES TEXTURES AUX CHAISES ---
# Parcourt les positions de chaises et leur assigne la texture personnalisée de chaise
func _apply_texture_to_chairs() -> void:
	if not custom_chair_texture:
		return
		
	for chair_node: Node in all_chair_positions:
		# On cherche récursivement le premier Sprite2D présent dans les descendants de ce marqueur
		var sprite = _find_sprite_recursive(chair_node)
		if sprite:
			sprite.texture = custom_chair_texture


# --- RECHERCHE RÉCURSIVE DE SPRITE ---
# Fonction auxiliaire récursive pour trouver un Sprite2D plus bas dans l'arbre d'une chaise
func _find_sprite_recursive(node: Node) -> Sprite2D:
	for child: Node in node.get_children():
		if child is Sprite2D:
			return child
		
		# Recherche plus bas s'il y a d'autres enfants
		var found = _find_sprite_recursive(child)
		if found:
			return found
			
	return null


# --- GESTION DE L'ARRIVÉE DU JOUEUR ---
# Exécuté lorsque le joueur arrive et interagit avec la table (pour nettoyer ou servir)
func _on_player_arrived(action_id: int)-> void:
	var player: Node = get_tree().get_first_node_in_group("Player")

	# Détermine si la table est dans un état où elle peut être nettoyée
	var can_clean: bool = current_state == GameEnums.TableState.WAITING_FOR_CLEANING \
		or (current_state == GameEnums.TableState.WAITING_FOR_PAYMENT and is_dirty)

	# Si elle doit être nettoyée, on lance la tâche de nettoyage
	if can_clean:
		_start_cleaning(player, action_id)
		return

	# Si la table a des clients servables et que le joueur possède un composant de staff, on simule un délai de livraison
	if order_component.has_servable_customer() and player and player.has_node("StaffComponent"):
		await player.staff_component.start_task(GameEnums.StaffState.DELIVERING, serving_delay)

	# S'il y a une action réservée, on envoie le nombre d'action et on réinitialise _reserved_by_action
	if action_id in _reserved_by_action:
		var reserved_count = _reserved_by_action[action_id]
		TrayManager.release_reservation(reserved_count)
		_reserved_by_action.erase(action_id)

	# Sert la nourriture aux clients et complète l'action d'interaction
	order_component.serve_food()
	interaction_component.complete_action(action_id)


# --- GESTION DE LA MISE EN FILE D'ATTENTE D'UNE ACTION ---
# Appelé lorsqu'une action est préparée/mise en file d'attente pour cette table
func _on_action_queued(action_id: int) -> void:
	var count_servable_items: int = order_component.count_servable_items()
	var can_clean: bool = current_state == GameEnums.TableState.WAITING_FOR_CLEANING \
		or (current_state == GameEnums.TableState.WAITING_FOR_PAYMENT and is_dirty)

	if can_clean:
		return

	if count_servable_items > 0:
		TrayManager.reserve_for_service(count_servable_items)
		_reserved_by_action[action_id] = count_servable_items


# --- PROCESSUS DE NETTOYAGE DE LA TABLE ---
# Exécute la tâche de nettoyage par le joueur, remet la table propre et réinitialise son état
func _start_cleaning(player: Node, action_id: int) -> void:
	if not player or not player.has_node("StaffComponent"):
		return

	# Lance l'animation/tâche de nettoyage avec la durée requise
	await player.staff_component.start_task(GameEnums.StaffState.CLEANING, cleaning_duration)

	# Nettoyage terminé : met à jour l'état de la table et cache la bulle
	is_dirty = false
	order_component.hide_order_bubble()

	# Si la table attendait d'être nettoyée, elle redevient entièrement libre et propre
	if current_state == GameEnums.TableState.WAITING_FOR_CLEANING:
		current_state = GameEnums.TableState.UNOCCUPIED_AND_CLEAN

	# Termine l'interaction en cours
	interaction_component.complete_action(action_id)


# --- VÉRIFICATION DE CAPACITÉ D'UN GROUPE ---
# Retourne vrai si la table n'est pas occupée et possède assez de chaises libres pour le groupe
func can_accommodate_group(group_size: int) -> bool:
	# 1. Vérifie si la table est déjà occupée
	if current_state != GameEnums.TableState.UNOCCUPIED_AND_CLEAN:
		return false
	
	# 2. Vérifie si la table a assez de chaises au total pour le groupe
	if all_chair_positions.size() < group_size:
		return false
		
	# 3. La table est libre et assez grande
	return true


# --- RÉSERVATION DES SIÈGES POUR UN GROUPE ---
# Marque un certain nombre de sièges comme occupés et retourne la liste des Marker2D correspondants
func reserve_seats(group_size: int) -> Array[Marker2D]:
	var reserved: Array[Marker2D] = []
	
	# 1. On garde la validation complète des états (sécurité pour éviter de réserver une table déjà en service ou en repas)
	if current_state == GameEnums.TableState.AWAITING_SERVICE or \
	   current_state == GameEnums.TableState.IN_MEAL:
		return []
	
	# 2. On boucle sur TOUTES les chaises disponibles
	# Au lieu de 'range(group_size)', on cherche celles qui ne sont pas dans 'occupied_seats'
	for seat: Marker2D in all_chair_positions:
		if not occupied_seats.has(seat):
			occupied_seats.append(seat) # On marque le siège comme pris
			reserved.append(seat)        # On l'ajoute à la liste pour le LevelComponent
			
			# Si on a trouvé assez de sièges pour tout le groupe, on arrête de chercher
			if reserved.size() == group_size:
				break
	
	# 3. Sécurité : si on n'a pas trouvé assez de places libres, on annule tout
	if reserved.size() < group_size:
		print("Erreur : pas assez de places libres trouvées")
		return []

	# 4. On met à jour l'état de la table (elle passe en attente de service)
	current_state = GameEnums.TableState.AWAITING_SERVICE

	# On renvoie la liste des Marker2D réservés
	return reserved
