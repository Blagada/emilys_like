extends CharacterBody2D
class_name Customer

@onready var visual_customer: Node2D = $VisualCustomer
@onready var collision_customer: CollisionShape2D = $CollisionCustomer
@onready var movement_component: MovementComponent = $Scripts/MovementComponent
@onready var patience_component: PatienceComponent = $Scripts/PatienceComponent

@export var order_bubble_anchor: Marker2D
@export var order_bubble_scene: PackedScene

var order_bubble: Node = null
signal state_changed(new_state: GameEnums.CustomerState, target_pos: Vector2)

var current_order: FoodData
var customer_data: CustomerData
var current_state: GameEnums.CustomerState


func _ready() -> void:
	patience_component.patience_state_changed.connect(_on_patience_state_changed)


func _physics_process(_delta: float) -> void:
	velocity = movement_component.get_velocity_for_movement()

	if velocity != Vector2.ZERO:
		move_and_slide()


func _on_patience_state_changed(new_state: GameEnums.PatienceState) -> void:
	if order_bubble:
		order_bubble.set_patience_icon(new_state)


func setup(visual: CustomerVisual, data: CustomerData) -> void:
	apply_data(data)

	for child: Node in visual_customer.get_children():
		child.queue_free()

	var skin: Node = visual.visual_scene.instantiate()
	visual_customer.add_child(skin)
	if skin.has_method("on_state_changed"):
		state_changed.connect(skin.on_state_changed)


func apply_data(new_data: CustomerData) -> void:
	customer_data = new_data
	movement_component.speed = new_data.speed


func change_state(new_state: GameEnums.CustomerState, target_pos: Vector2 = Vector2.ZERO) -> void:
	current_state = new_state
	state_changed.emit(new_state, target_pos)


func show_order_bubble(food: FoodData) -> void:
	_ensure_bubble_instance()
	var typed_array: Array[FoodData] = [food]
	order_bubble.show_orders(typed_array)


func show_thinking() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("...")


func show_waiting_payment_bubble() -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("$")


func show_bill_amount(amount: float) -> void:
	_ensure_bubble_instance()
	order_bubble.show_text("%.2f$" % amount)


func hide_bubble() -> void:
	if order_bubble:
		order_bubble.queue_free()
		order_bubble = null


func _ensure_bubble_instance() -> void:
	if order_bubble == null:
		order_bubble = order_bubble_scene.instantiate()
		order_bubble_anchor.add_child(order_bubble)


func set_order(food: FoodData)-> void:
	current_order = food


func move_to_table(table_marker: Marker2D, table_position: Vector2) -> void:
	change_state(GameEnums.CustomerState.MOVING)
	movement_component.set_target(table_marker.global_position)
	await movement_component.destination_reached

	change_state(GameEnums.CustomerState.SITTING, table_position)
	collision_customer.set_deferred("disabled", true)

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", table_marker.global_position, 0.3)


func move_to(target_marker: Marker2D, state: GameEnums.CustomerState = GameEnums.CustomerState.MOVING) -> void:
	change_state(state, target_marker.global_position)
	collision_customer.set_deferred("disabled", false)
	movement_component.set_target(target_marker.global_position)
	await movement_component.destination_reached
