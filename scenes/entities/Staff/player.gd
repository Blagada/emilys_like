extends CharacterBody2D
class_name Player

@onready var movement_component: MovementComponent = $MovementComponent
@onready var animation: AnimationPlayer = $body/Animation
@onready var body: AnimatedSprite2D = $body

var is_busy: bool = false

func set_movement_target(target_point: Vector2) -> void:
	# vers quoi le player va se déplacer
	movement_component.set_target(target_point)

func _physics_process(_delta: float) -> void:
	velocity = movement_component.get_velocity_for_movement()
	
	if velocity != Vector2.ZERO:
		if animation.current_animation != "walk":
			animation.play("walk")
		body.flip_h = velocity.x > 0
		move_and_slide()
	else:
		if animation.current_animation != "idle":
			animation.play("idle")
