extends Control
class_name PaymentFeedbackDisplay

# Durée totale d'affichage du feedback à l'écran avant de se masquer
@export var feedback_display_duration: float = 3.0
@export var feedback_text: RichTextLabel

## Affiche le récapitulatif du paiement de manière instantanée
func show_payment(bill: float, tip: float, combo_bonus: float) -> void:
	# Initialise le tableau de texte avec le montant principal formaté
	var parts: Array[String] = [CurrencyService.format(bill)]

	# Ajoute le bonus de combo s'il est actif (supérieur à 0)
	if combo_bonus > 0.0:
		parts.append(tr("FEEDBACK_COMBO") % CurrencyService.format(combo_bonus))

	# Ajoute le pourboire s'il est supérieur à 0
	if tip > 0.0:
		parts.append(tr("FEEDBACK_TIP") % CurrencyService.format(tip))

	# Assemble toutes les lignes avec des sauts de ligne
	feedback_text.text = "\n".join(parts)
	
	# Affichage direct sans animation
	visible = true

	# Attend le délai configuré
	await get_tree().create_timer(feedback_display_duration, false).timeout

	# Masque le libellé
	visible = false
