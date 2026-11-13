extends PanelContainer
class_name LevelBar

signal primary_pressed
signal catalog_pressed
signal visit_pressed

@export var primary_button: Button
@export var catalog_button: Button
@export var visit_button: Button


func _ready() -> void:
	primary_button.pressed.connect(_on_primary_button_pressed)
	catalog_button.pressed.connect(_on_catalog_button_pressed)
	visit_button.pressed.connect(_on_visit_button_pressed)
	
	
func _on_primary_button_pressed() -> void:
	primary_pressed.emit()

func _on_catalog_button_pressed() -> void:
	catalog_pressed.emit()

func _on_visit_button_pressed() -> void:
	visit_pressed.emit()
