extends CharacterBody2D
class_name Player

@onready var movement_component: MovementComponent = $MovementComponent
@onready var animation: AnimationPlayer = $body/Animation
@onready var body: AnimatedSprite2D = $body
@onready var staff_component: StaffComponent = $StaffComponent

var is_busy: bool = false

const STATE_ANIMATIONS: Dictionary = {
	GameEnums.StaffState.WAITING: "idle",
	GameEnums.StaffState.MOVING: "walk",
	GameEnums.StaffState.FOOD_PREP: "idle", # TODO : À changer pour food_prep
	GameEnums.StaffState.DELIVERING: "walk", # TODO : À changer pour delivering
	GameEnums.StaffState.CLEANING: "idle", # TODO : à changer pour cleaning
}


func _ready() -> void:
	staff_component.state_changed.connect(_on_staff_state_changed)


func set_movement_target(target_point: Vector2) -> void:
	movement_component.set_target(target_point)


func _physics_process(_delta: float) -> void:
	velocity = movement_component.get_velocity_for_movement()

	if velocity != Vector2.ZERO:
		staff_component.set_moving()
		body.flip_h = velocity.x > 0
		move_and_slide()
	else:
		staff_component.set_idle()


func _on_staff_state_changed(new_state: GameEnums.StaffState) -> void:
	var anim_name: String = _get_animation_for_state(new_state)
	if animation.current_animation != anim_name:
		animation.play(anim_name)


func _get_animation_for_state(state: GameEnums.StaffState) -> String:
	if state == GameEnums.StaffState.MOVING and not GameDataManager.tray_items.is_empty():
		return "walk" # TODO: remplacer par delivering lorsque prête

	return STATE_ANIMATIONS.get(state, "idle")
