extends Node

class_name TableComponent
# À besoin du Node ChairPositions avec des Marker2D pour gérer la position des chaises.

@onready var all_chair_positions = chair_positions.get_children()
@export var chair_positions: Node2D

@export var current_state = GameEnums.TableState.LIBRE_PROPRE # Par défaut, toutes les chaises sont libre et propre
var occupied_seats = [] # Liste pour garder en mémoire quels sièges sont pris


# Retourne vrai la table n'est pas occupé et elle a assez de chaises libres
func can_accommodate_group(group_size: int) -> bool:
	# 1. Vérifie si la table est déjà occupée
	if current_state != GameEnums.TableState.LIBRE_PROPRE:
		return false
	
	# 2. Vérifie si la table a assez de chaises pour le groupe
	if all_chair_positions.size() < group_size:
		return false
		
	# 3. La table est libre et assez grande
	return true


func reserve_seats(group_size: int) -> Array[Marker2D]:
	var reserved: Array[Marker2D] = []
	
	# 1. On garde TA validation complète des états (sécurité)
	if current_state == GameEnums.TableState.OCCUPE_SANS_COMMANDE or \
	   current_state == GameEnums.TableState.OCCUPE_AVEC_COMMANDE:
		return []
	
	# 2. On boucle sur TOUTES les chaises disponibles
	# Au lieu de 'range(group_size)', on cherche celles qui ne sont pas dans 'occupied_seats'
	for seat in all_chair_positions:
		if not occupied_seats.has(seat):
			occupied_seats.append(seat) # On marque le siège comme pris
			reserved.append(seat)       # On l'ajoute à la liste pour le LevelComponent
			
			# --- DEBUG ICI ---
			print("Table [", name, "] : Siège assigné à la position : ", seat.position)
			
			# Si on a assez de sièges, on arrête de chercher
			if reserved.size() == group_size:
				break
	
	# 3. Sécurité : si on n'a pas trouvé assez de places, on annule tout
	if reserved.size() < group_size:
		print("Erreur : pas assez de places libres trouvées")
		return []

	# 4. On met à jour l'état comme tu le faisais
	current_state = GameEnums.TableState.OCCUPE_SANS_COMMANDE
	print("Table [", name, "] : Réservée pour ", group_size, " personnes.")

	# On renvoie bien les Marker2D, comme avant
	return reserved
