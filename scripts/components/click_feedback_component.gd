extends Node
class_name ClickFeedbackComponent

enum FeedbackType { SCALE_PUNCH, COLOR_FLASH }

@export var target_sprite: Node2D
@export var interaction_component: Interactable
@export var feedback_type: FeedbackType = FeedbackType.COLOR_FLASH

@export_group("Scale Punch")
@export var punch_scale_multiplier: float = 1.15
@export var punch_duration: float = 0.08

@export_group("Color Flash")
@export var flash_color: Color = Color(1.4, 1.4, 1.4)
@export var flash_duration: float = 0.3
@export var click_flash_count: int = 2

var _base_scale: Vector2
var _base_modulate: Color
var _active_tween: Tween


func _ready() -> void:
	if interaction_component:
		interaction_component.action_queued.connect(_on_action_queued)
		interaction_component.hover_started.connect(_on_hover_started)

	call_deferred("_capture_base_values")


func _on_hover_started() -> void:
	if feedback_type == FeedbackType.COLOR_FLASH:
		_play_color_flash()


func _capture_base_values() -> void:
	if target_sprite:
		_base_scale = target_sprite.scale
		_base_modulate = target_sprite.modulate


func _on_action_queued(_action_id: int) -> void:
	match feedback_type:
		FeedbackType.SCALE_PUNCH:
			_play_scale_punch()
		FeedbackType.COLOR_FLASH:
			_play_multi_flash(click_flash_count)


func _play_scale_punch() -> void:
	if not target_sprite:
		return
	_kill_active_tween()
	target_sprite.scale = _base_scale

	_active_tween = create_tween()
	_active_tween.tween_property(target_sprite, "scale", _base_scale * punch_scale_multiplier, punch_duration)
	_active_tween.tween_property(target_sprite, "scale", _base_scale, punch_duration)


func _play_color_flash() -> void:
	if not target_sprite:
		return
	_kill_active_tween()
	target_sprite.modulate = _base_modulate

	_active_tween = create_tween()
	_active_tween.tween_property(target_sprite, "modulate", flash_color, flash_duration)
	_active_tween.tween_property(target_sprite, "modulate", _base_modulate, flash_duration)


func _play_multi_flash(times: int) -> void:
	if not target_sprite:
		return
	_kill_active_tween()
	target_sprite.modulate = _base_modulate

	_active_tween = create_tween()
	for i in range(times):
		_active_tween.tween_property(target_sprite, "modulate", flash_color, flash_duration)
		_active_tween.tween_property(target_sprite, "modulate", _base_modulate, flash_duration)


func _kill_active_tween() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
