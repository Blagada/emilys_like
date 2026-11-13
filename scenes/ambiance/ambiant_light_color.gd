extends Node2D
class_name AmbiantLightColor

@export var light_canvas: CanvasModulate


func _ready() -> void:
	# Se connecte au signal de météo
	WeatherComponent.weather_changed.connect(_on_weather_changed)

	
func _on_weather_changed(weather: WeatherData) -> void:
	var c: Color = weather.light_color
	var e: float = weather.light_energy
	# Associe la couleur et l'énergie de la lumière dans la ressource météo
	light_canvas.color = Color(c.r * e, c.g * e, c.b * e, 1.0)
