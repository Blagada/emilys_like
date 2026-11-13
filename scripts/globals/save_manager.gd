extends Node2D

const PREFS_PATH: String = "user://settings.json"

# Un dictionnaire en mémoire pour éviter de relire le fichier sans arrêt
var _settings: Dictionary = {}

func _ready() -> void:
	# Chargement de la sauvegarde au lancement du jeu
	_settings = save_load()
	apply_settings()


# Applique les valeurs chargées au moteur
func apply_settings() -> void:
	var theme_global: Theme = ThemeDB.get_project_theme()

	if _settings.has("font") and GameEnums.POLICES.has(_settings["font"]):
		theme_global.default_font = GameEnums.POLICES[_settings["font"]] as Font

	if _settings.has("font_size"):
		theme_global.default_font_size = int(_settings["font_size"])
	
	if _settings.has("language_code"):
		TranslationServer.set_locale(_settings["language_code"])


func saving_font(font_name: String) -> void:
	_settings["font"] = font_name # Met à jour la mémoire
	save_file(_settings)          # Sauvegarde sur le disque


func saving_font_size(font_size: float) -> void:
	_settings["font_size"] = font_size
	save_file(_settings)


func saving_language(language_code: String) -> void:
	_settings["language_code"] = language_code
	save_file(_settings)


func save_file(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(PREFS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func save_load() -> Dictionary:
	if not FileAccess.file_exists(PREFS_PATH):
		return {}

	var file: FileAccess = FileAccess.open(PREFS_PATH, FileAccess.READ)
	if not file:
		return {}

	var contenu: String = file.get_as_text()
	file.close()

	var data: Variant = JSON.parse_string(contenu)
	return data as Dictionary if data is Dictionary else {}
