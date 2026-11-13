@tool
class_name ColoredPanel
extends ColorRect

@export var panel_color: Color = Color(0.1, 0.5, 0.25):
	set(value):
		panel_color = value
		_update_shader()

@export var pixel_size: float = 3.0:
	set(value):
		pixel_size = value
		_update_shader()

@export var use_gradient: bool = true:
	set(value):
		use_gradient = value
		_update_shader()

@export_range(0.0, 1.0) var gradient_strength: float = 0.5:
	set(value):
		gradient_strength = value
		_update_shader()

@export var corner_radius: float = 12.0:
	set(value):
		corner_radius = value
		_update_shader()

@export_range(0.0, 360.0) var gradient_angle: float = 0.0:
	set(value):
		gradient_angle = value
		_update_shader()


func _ready() -> void:
	resized.connect(_update_shader)
	_update_shader()


func _update_shader() -> void:
	var shader_material := material as ShaderMaterial
	if shader_material == null:
		return
	shader_material.set_shader_parameter("base_color", panel_color)
	shader_material.set_shader_parameter("panel_size", size)
	shader_material.set_shader_parameter("pixel_size", pixel_size)
	shader_material.set_shader_parameter("use_gradient", use_gradient)
	shader_material.set_shader_parameter("gradient_strength", gradient_strength)
	shader_material.set_shader_parameter("corner_radius", corner_radius)
	shader_material.set_shader_parameter("gradient_angle", gradient_angle)
