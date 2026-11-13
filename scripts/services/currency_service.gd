class_name CurrencyService

static func format(amount: float, decimals: int = 2) -> String:
	var number: String = ("%." + str(decimals) + "f") % amount
	return TranslationServer.translate("CURRENCY_FORMAT").format({
		"symbol": TranslationServer.translate("CURRENCY_SYMBOL"),
		"amount": number
	})
