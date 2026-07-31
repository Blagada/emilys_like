extends TextureProgressBar
class_name DayClock

@export var day_cycle: DayCycleComponent
@export var markers_container: Control


func _ready() -> void:
	fill_mode = TextureProgressBar.FILL_CLOCKWISE
	max_value = 1.0
	step = 0.0
	value = 0.0


func _process(_delta: float) -> void:
	if day_cycle.total_day_duration <= 0.0:
		return
	value = day_cycle.elapsed_time / day_cycle.total_day_duration


func setup_markers(service_count: int) -> void:
	for child: Node in markers_container.get_children():
		child.queue_free()

	if service_count <= 1:
		return

	var radius: float = size.x / 2.0
	var center: Vector2 = Vector2(radius, radius)

	for i: int in range(1, service_count):
		var angle: float = (TAU * float(i) / float(service_count)) - (PI / 2.0)
		var marker: ColorRect = ColorRect.new()
		marker.size = Vector2(6, 6)
		marker.color = Color.BLACK
		marker.position = center + Vector2(cos(angle), sin(angle)) * (radius - 8) - (marker.size / 2.0)
		markers_container.add_child(marker)
