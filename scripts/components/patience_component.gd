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


# --- DÉMARRE LE DÉCOMPTE DE PATIENCE ---
# TODO: réinitialiser _elapsed à 0, assigner _duration, remettre _current_state à HAPPY,
# et activer _is_active à true
func start(duration: float) -> void:
	for x in patience_expired.get_connections():
		patience_expired.disconnect(x.callable)

	_elapsed = 0
	_duration = duration
	_current_state = GameEnums.PatienceState.HAPPY
	_is_active = true


# --- ANNULE LE DÉCOMPTE (ex: client servi/assis/payé à temps) ---
func cancel() -> void:
	_is_active = false


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
