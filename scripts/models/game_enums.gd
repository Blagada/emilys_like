class_name GameEnums


enum TableState {
	UNOCCUPIED_AND_CLEAN, # État par défaut, libre et propre
	AWAITING_SERVICE, # Commande faite, en attente de service
	IN_MEAL, # Tous servis, mangent
	WAITING_FOR_PAYMENT, # Tous ont fini de manger, attendent le paiement
	WAITING_FOR_CLEANING # Tous partis, mais besoin de nettoyage
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


# Enum pour les états du staff (dont le joueur) : prévision des animations
enum StaffState {
	WAITING, # idle
	MOVING, # walk
	FOOD_PREP, # préparation de la nourriture
	DELIVERING, # apporter la nourriture à table
	CLEANING # Nettoyage de la table (du comptoir peut-être aussi?)
}


enum CustomerType {
	NONE = 0,
	CUSTOMER_NORMAL,
	CUSTOMER_VIP,
	CUSTOMER_PRESS,
	CUSTOMER_CALM
}
