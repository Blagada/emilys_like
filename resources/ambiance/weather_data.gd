extends Resource
class_name WeatherData

@export_group("Identité")
@export var state: GameEnums.WeatherState
@export var api_codes: Array[int] = []

@export_group("Visuel")
@export var overlay_scene: PackedScene
@export var light_color: Color = Color.WHITE
@export var light_energy: float = 1.0

@export_group("Ambiance sonore")
@export var ambient_sound: AudioStream
@export var ambient_volume_db: float = 0.0
