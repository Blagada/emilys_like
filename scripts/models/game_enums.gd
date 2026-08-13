class_name GameEnums

# ---- ENUMS ----- #
enum TableState {
	UNOCCUPIED_AND_CLEAN, # État par défaut, libre et propre
	AWAITING_SERVICE, # Commande faite, en attente de service
	IN_MEAL, # Tous servis, mangent
	WAITING_FOR_PAYMENT, # Tous ont fini de manger, attendent le paiement
	WAITING_FOR_CLEANING # Tous partis, mais besoin de nettoyage
}


# Enum pour les états du staff (dont le joueur) : prévision des animations
enum StaffState {
	WAITING, # idle
	MOVING, # walk
	FOOD_PREP, # préparation de la nourriture
	DELIVERING, # apporter la nourriture à table
	CLEANING # Nettoyage de la table (du comptoir peut-être aussi?)
}


# Enum pour les états de clients : prévision des animations
enum CustomerState {
	WAITING_FOR_TABLE, # attend une table
	MOVING, # se déplace : vers la table; vers la sortie
	SITTING, # est assis
	WAITING_TO_ORDER, # menu à la main
	ORDERING, # donner sa commande
	EATING, # mange
	WAITING_FOR_PAYMENT, # assis à table, en attente que le représentant paye
	PAYING # Animation du représentant au comptoir pour payer
}

enum CustomerType {
	CUSTOMER_NORMAL,
	CUSTOMER_VIP,
	CUSTOMER_PRESS,
	CUSTOMER_CALM
}

enum PatienceState {
	HAPPY,   # 100% → seuil "impatient"
	IMPATIENT, # seuil "impatient" → seuil "fâché"
	ANGRY      # seuil "fâché" → 0%
}

enum foodType {
	PREPARED, # déjà préparé
	COMBO, # doit être assemblé avec 2 ou plus aliments
	OVEN, # prend une cuisson au four
	COOKTOP # prend une cuisson sur la plaque
}

enum ServiceType {
	BREAKFAST,
	LUNCH,
	DINNER
}

# ---- Dictionaire ---- #
const SERVICE_TYPE_LABELS: Dictionary = {
	ServiceType.BREAKFAST: "déjeuner",
	ServiceType.LUNCH: "dîner",
	ServiceType.DINNER: "souper",
}

const CUSTOMER_TYPE_LABELS: Dictionary = {
	CustomerType.CUSTOMER_NORMAL: "régulier",
	CustomerType.CUSTOMER_VIP: "VIP",
	CustomerType.CUSTOMER_PRESS: "pressé",
	CustomerType.CUSTOMER_CALM: "tranquille",
}
