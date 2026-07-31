extends Node
class_name SunLightController

@export var light: DirectionalLight2D
@export var day_clock: DayClock
@export var start_angle_degrees: float = -50.0
@export var end_angle_degrees: float = 50.0


func _process(_delta: float) -> void:
	var t: float = day_clock.value
	light.rotation_degrees = lerp(start_angle_degrees, end_angle_degrees, t)
