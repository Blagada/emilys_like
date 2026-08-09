extends Node
class_name PatienceComponent

# --- SIGNAUX ---
signal patience_expired
signal patience_state_changed(new_state: GameEnums.PatienceState)

# --- EXPORTS & CONFIGURATIONS ---
@export var impatient_threshold_percent: float = 50.0
@export var angry_threshold_percent: float = 20.0

# --- VARIABLES D'ÉTAT ---
var _duration: float = 0.0
var _elapsed: float = 0.0
var _is_active: bool = false
var _current_state: GameEnums.PatienceState = GameEnums.PatienceState.HAPPY

# --- BOUCLE DE DÉCOMPTE ---
func _process(delta: float) -> void:
	# Si is active est à false, on sort de _process
	if _is_active == false:
		return
	
	# incrémente _elapsed pour créer un décompte
	_elapsed += delta	
	
	if _elapsed >= _duration:
		# Si _elapsed est plus grand ou égale à la durée de la patience, la patience est expiré, le timer est arrêté.
		patience_expired.emit()
		_is_active = false
		return
	else:
		# Sinon vérifie si on a changé de palier
		_update_state()


# --- DÉMARRE LE DÉCOMPTE DE PATIENCE ---
func start(duration: float, starting_state: GameEnums.PatienceState = GameEnums.PatienceState.HAPPY) -> void:
	#for x in patience_expired.get_connections():
	#	patience_expired.disconnect(x.callable)

	_duration = duration
	# validation du state par défaut
	match starting_state:
		GameEnums.PatienceState.HAPPY: _elapsed = 0.0
		GameEnums.PatienceState.IMPATIENT: _elapsed = _duration * (1.0 - impatient_threshold_percent / 100.0)
		GameEnums.PatienceState.ANGRY: _elapsed = _duration * (1.0 - angry_threshold_percent / 100.0)

	_current_state = starting_state
	_is_active = true

	# Emmet le changement d'état pour modifier l'icône
	if starting_state != GameEnums.PatienceState.HAPPY:
		patience_state_changed.emit(starting_state)

# --- ANNULE LE DÉCOMPTE (ex: client servi/assis/payé à temps) ---
func cancel() -> void:
	_is_active = false


# --- CALCULE LE % RESTANT ET VÉRIFIE LE CHANGEMENT DE PALIER ---
func _update_state() -> void:
	# Combien de temps est passé, en pourcentage
	var remaining_percent: float = (1.0 - (_elapsed / _duration)) * 100.0
	var new_state: GameEnums.PatienceState = _current_state
	
	# Vérifie le palier : angry ou impatient
	if remaining_percent <= angry_threshold_percent:
		new_state = GameEnums.PatienceState.ANGRY
	elif remaining_percent <= impatient_threshold_percent:
		new_state = GameEnums.PatienceState.IMPATIENT

	if new_state != _current_state:
		_current_state = new_state
		patience_state_changed.emit(_current_state)


# --- RETOURNE LE PALIER ACTUEL, SANS MODIFIER L'ÉTAT ---
func get_current_state() -> GameEnums.PatienceState:
	return _current_state
