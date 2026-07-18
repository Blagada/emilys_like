class_name GameEnums

enum TableState {
	LIBRE_PROPRE,
	LIBRE_SALE,
	EN_ATTENTE_SERVICE,
	EN_REPAS,
	ATTENTE_PAIEMENT
}

enum CustomerType {
	CLIENT_NORMAL,
	CLIENT_VIP,
	CLIENT_PRESSE,
	CLIENT_TRANQUILLE
}

enum CustomerState {
	WAITING_FOR_TABLE, # attend une table
	MOVING, # se déplace
	SITTING, # est assis
	WAITING_TO_ORDER, # menu à la main
	ORDERING, # prêt à donner sa commande
	EATING, # mange
	WAITING_FOR_PAIEMENT # attend pour payer
}
