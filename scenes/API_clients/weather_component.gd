extends Node2D

@onready var http_request: HTTPRequest = $HTTPRequest
@export var weather_list: Array[WeatherData] = []
@export var default_weather: WeatherData

signal weather_changed(weather: WeatherData)

var _api_key: String = ""
var _weather_by_code: Dictionary[int, WeatherData] = {}
var current_weather: WeatherData

func _ready() -> void:
	# Va chercher la valeur par défaut, avant de valider la météo du jour
	current_weather = default_weather
	# Va chercher la clé de l'API
	_api_key = _load_api_key()

	_build_code_map()
	
	# Appel l'API avec la clé et les propriétés q=auto:ip qui permet de géolocaliser
	http_request.request_completed.connect(_on_request_completed)
	var api_path: String = "https://api.weatherapi.com/v1/current.json?key=%s&q=auto:ip" % [_api_key]
	var request_response = http_request.request(api_path)
	if request_response != OK:
		push_warning("Weather API : impossible de se connecter à l'API")
		return
	


func _load_api_key() -> String:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load("res://secrets.cfg")
	if error != OK:
		push_warning("WeatherComponent : impossible de lire secrets.cfg (erreur %d)" % error)
		return ""
	return config.get_value("api", "weather_key", "") as String


func _on_request_completed(
	result: int,
	response_code: int,
	_header: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result !=0 or response_code != 200:
		push_warning("Erreur d'appel à WeatherAPI : résultat, ", result, ", code, ", response_code)
		return

	var api_body: String = body.get_string_from_utf8()
	var data: Variant = JSON.parse_string(api_body)

	if not data is Dictionary:
		push_warning("WeatherComponent : Pas de donné provenant de l'API Weather.")
		return
	
	# Va chercher le code de la météo courante dans l'API
	var code: int = int(data["current"]["condition"]["code"])
	var condition = data["current"]["condition"]["text"]
	print("météo courante : ", condition)
	# Associe la valeur courante de la météo à la variable global current_weather
	current_weather = _weather_by_code.get(code, default_weather)
	weather_changed.emit(current_weather)


func _build_code_map() -> void:
	for weather in weather_list:
		for code in weather.api_codes:
			if _weather_by_code.has(code):
				push_warning("WeatherComponent : le code %d est dans plusieurs ressources" % code)
				continue
			_weather_by_code[code] = weather
