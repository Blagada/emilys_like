extends Node

# --- SIGNAUX ---
# Émis lorsque les éléments présents sur le plateau changent (ajout, suppression, etc.)
signal tray_updated
# Émis lorsque la liste des éléments en attente est modifiée
signal pending_updated

# --- VARIABLES D'ÉTAT DU PLATEAU ET DES COMMANDES ---
var tray_items: Array[FoodData] = []          # Liste des plats actuellement physiquement sur le plateau
var pending_items: Array[Dictionary] = []     # Liste des plats commandés en cours de préparation (contient l'id, les données du plat et l'état d'annulation)
var current_max_capacity: int = 3             # Capacité maximale autorisée sur le plateau
var item_target_size: int = 55                # Taille cible d'affichage des icônes d'aliments
var reserved_for_service: int = 0             # Si le tray est plein, et que le player va faire un service, réserve des actions à mettre dans la file


# --- VIDE ENTIÈREMENT LE PLATEAU DE SES ALIMENTS ---
func clear_tray() -> void:
	tray_items.clear()
	tray_updated.emit()


# --- AJOUTE UN ALIMENT EN ATTENTE DE PRÉPARATION/RÉCUPÉRATION ---
func add_pending_item(action_id: int, food_data: FoodData) -> void:
	# Enregistre l'action, les données du plat et on initialise le drapeau d'annulation à faux
	pending_items.append({"action_id": action_id, "food_data": food_data, "cancel_requested": false})
	pending_updated.emit()


# --- RÉSERVE UN NB DE PENDING AUX PROCHAINES ACTIONS
func reserve_for_service(count: int) -> int:
	reserved_for_service += count
	return reserved_for_service

# --- SOUSTRAIT UN NB DE PENDING AUX PROCHAINES ACTIONS
func release_reservation(count: int) -> int:
	reserved_for_service = max(0, reserved_for_service - count)
	return reserved_for_service


# --- DEMANDE L'ANNULATION D'UN ALIMENT EN ATTENTE VIA SON ID ---
func request_cancel_pending_item(action_id: int) -> void:
	for entry: Dictionary in pending_items:
		if entry["action_id"] == action_id:
			entry["cancel_requested"] = true
			return


# --- SUPPRIME COMPLÈTEMENT UN ALIMENT EN ATTENTE DE LA LISTE ---
func remove_pending_item(action_id: int) -> void:
	for i: int in range(pending_items.size()):
		if pending_items[i]["action_id"] == action_id:
			pending_items.remove_at(i)
			pending_updated.emit()
			return


# --- CONSOMME/RETIRE UN ALIMENT EN ATTENTE ET RETOURNE S'IL A ÉTÉ ANNULÉ ---
func consume_pending_item(action_id: int) -> bool:
	for i: int in range(pending_items.size()):
		if pending_items[i]["action_id"] == action_id:
			# Sauvegarde l'état d'annulation avant de nettoyer l'élément de la liste
			var was_cancelled: bool = pending_items[i]["cancel_requested"]
			pending_items.remove_at(i)
			pending_updated.emit()
			return was_cancelled
	return false
