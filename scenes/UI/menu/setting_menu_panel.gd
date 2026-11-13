extends Control
class_name SettingMenuPanel

@export var weather_check: CheckButton
@export var season_event_check: CheckButton
@export var language_options: OptionButton
@export var font_options: OptionButton
@export var font_size_options: HSlider
@export var font_size_value: Label

func _ready() -> void:
	_set_font_size_label()
	_set_language_options()
	_set_font_options()
	_set_weather_option()


func _set_font_options() -> void:
	font_options.clear()
	for nom_police: String in GameEnums.POLICES.keys():
		font_options.add_item(nom_police)	
	# Valeur sauvegardé
	var saved_font: String = SaveManager._settings["font"]
	var index: int = GameEnums.POLICES.keys().find(saved_font)
	# Si une font a été sauvegardé
	if index != -1:
		font_options.selected = index


func _set_font_size_label() -> void:
	# S'il y a une taille sauvegardé
	if SaveManager._settings["font_size"]:
		font_size_value.text = tr("%dpx") % SaveManager._settings["font_size"]
		font_size_options.value = SaveManager._settings["font_size"]
	else:
		font_size_value.text = tr("%dpx") % font_size_options.value


func _set_language_options() -> void:
	var selected_index: int = 0
	var current_locale: String = TranslationServer.get_locale()
	var locales: PackedStringArray = TranslationServer.get_loaded_locales()

	for i: int in locales.size():
		var locale: String = locales[i]
		language_options.add_item(_get_language_label(locale))
		language_options.set_item_metadata(i, locale)
		language_options.selected = i
		if TranslationServer.compare_locales(locale, current_locale) > 0:
			selected_index = i

	language_options.select(selected_index)
	language_options.item_selected.connect(_on_language_selected)


func _set_weather_option() -> void:
	weather_check.toggle_mode = true


func _get_language_label(locale: String) -> String:
	var translation: Translation = TranslationServer.get_translation_object(locale)
	if translation == null:
		return TranslationServer.get_language_name(locale)

	var language_name: String = translation.get_message("LANGUAGE_NAME")
	if language_name.is_empty():
		return TranslationServer.get_language_name(locale)		
	return language_name


func _on_language_selected(index: int) -> void:
	var locale: String = language_options.get_item_metadata(index)
	TranslationServer.set_locale(locale)
	SaveManager.saving_language(locale)


func _on_font_options_item_selected(index: int) -> void:
	# Récupération sécurisée du nom de la police
	var nom_police: String = font_options.get_item_text(index)
	
	# Mise à jour typée du thème global
	if GameEnums.POLICES.has(nom_police):
		var theme_global: Theme = ThemeDB.get_project_theme()
		theme_global.default_font = GameEnums.POLICES[nom_police] as Font
		SaveManager.saving_font(nom_police)


func _on_font_size_slider_value_changed(value: float) -> void:
	var theme_global: Theme = ThemeDB.get_project_theme()
	theme_global.default_font_size = int(value)
	SaveManager.saving_font_size(value)
	_set_font_size_label()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	visible = false
