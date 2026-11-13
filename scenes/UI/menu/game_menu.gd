extends Control
class_name GameMenu

signal menu_pressed

@export var menu_button: Button
@export var menu_panel: Control
@export var backdrop: Control
@export var setting_menu: SettingMenuPanel

var panel_open = false

func _ready() -> void:
	menu_panel.visible = false
	backdrop.visible = false
	setting_menu.visible = false


func _on_menu_button_toggled(toggled_on: bool) -> void:
	_set_open(toggled_on)


func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_set_open(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and menu_panel.visible:
		_set_open(false)
		get_viewport().set_input_as_handled()


func _set_open(is_open: bool) -> void:
	menu_panel.visible = is_open
	backdrop.visible = is_open
	menu_button.set_pressed_no_signal(is_open)
	menu_pressed.emit(is_open)


func _on_setting_button_pressed() -> void:
	_set_open(false)
	get_tree().paused = true
	setting_menu.visible = true
