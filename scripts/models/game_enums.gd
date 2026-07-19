class_name GameEnums

enum TableState {
	NONE = 0, # pour tester l'initialisation
	OCCUPIED_CLEAN,
	OCCUPIED_DIRTY,
	AWAITING_SERVICE,
	IN_MEAL,
	WAITING_FOR_PAYMENT
}

enum CustomerType {
	NONE = 0,
	CUSTOMER_NORMAL,
	CUSTOMER_VIP,
	CUSTOMER_PRESS,
	CUSTOMER_CALM
}

enum CustomerState {
	NONE = 0,
	WAITING_FOR_TABLE, # attend une table
	MOVING, # se déplace
	SITTING, # est assis
	WAITING_TO_ORDER, # menu à la main
	ORDERING, # prêt à donner sa commande
	EATING, # mange
	WAITING_FOR_PAYMENT # attend pour payer
}
