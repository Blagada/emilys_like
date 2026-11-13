extends Node2D
class_name BonusStarComponent

@export var float_distance: float = 40.0
@export var pop_duration: float = 0.2
@export var float_duration: float = 0.5

func play() -> void:
	scale = Vector2.ZERO
	modulate.a = 1.0
	visible = true

	var tween: Tween = create_tween()
	# Étape 1 : le "punch" d'apparition (scale 0 -> 1)
	tween.tween_property(self, "scale", Vector2.ONE, pop_duration)

	# Étape 2 : flotte vers le haut ET disparaît en même temps
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - float_distance, float_duration)
	tween.tween_property(self, "modulate:a", 0.0, float_duration)

	# Étape 3 : une fois fini, on cache (pour pouvoir réutiliser au prochain bonus)
	tween.chain().tween_callback(func(): visible = false)
