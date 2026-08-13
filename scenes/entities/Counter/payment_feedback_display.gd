extends Label
class_name PaymentFeedbackDisplay

@export var feedback_display_duration: float = 3.0


func show_payment(bill: float, tip: float, combo_bonus: float) -> void:
	var feedback_text: String = "%.2f$ (+ %.2f$ tip)" % [bill, tip]

	if combo_bonus > 0.0:
		feedback_text += " + combo : %.2f$" % [combo_bonus]

	text = feedback_text
	pivot_offset = size / 2
	modulate.a = 0.0
	scale = Vector2.ZERO
	visible = true

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

	await get_tree().create_timer(feedback_display_duration).timeout

	var fade_out: Tween = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.3)
	await fade_out.finished

	visible = false
