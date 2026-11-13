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

enum FoodType {
	PREPARED, # déjà préparé
	COMBO, # doit être assemblé avec 2 ou plus aliments
	OVEN, # prend une cuisson au four
	PIZZA_OVEN, # prend une cuisson dans un four à pizza
	SAUTE, # poêle : il faut faire sauter. Prend une cuisson sur la plaque
	SIMMER, # chaudron : il faut brasser. Prend une cuisson sur la plaque
	GRIDDLE, # Plaque de cuisson
	DRINK # délai différent possible (café, chocolat chaud, bière)
}

enum FoodTag {
	VEGETARIAN,
	SPICY,
	CAFFEINATED,
	ALCOHOL,
	RAW
}

enum ServiceType {
	BREAKFAST,
	LUNCH,
	DINNER
}

enum WeatherState {
	CLEAR,
	CLOUDY,
	FOG,
	RAIN,
	SNOW
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

const POLICES: Dictionary = {
	"GistPixel": preload("res://assets/fonts/Geist_Pixel/GeistPixel-Regular-VariableFont_ELSH.ttf"),
	"AtkinsonHyperlegible": preload("res://assets/fonts/Atkinson_Hyperlegible/AtkinsonHyperlegible-Regular.ttf"),
	"Averia": preload("res://assets/fonts/Averia_Serif_Libre/AveriaSerifLibre-Light.ttf"),	
	"Lora": preload("res://assets/fonts/Lora/Lora-VariableFont_wght.ttf"),
	"RadioCanada": preload("res://assets/fonts/Radio_Canada/RadioCanada-VariableFont_wdth,wght.ttf")
}
