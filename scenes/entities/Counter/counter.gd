extends Node2D

# Scène du visuel du comptoir
@export var visual_counter_scene: PackedScene

# Node pour positionneer la scène du comptoir
@export var visual_counter: Node2D

func _ready() -> void:
	var counter: Node = visual_counter_scene.instantiate()
	visual_counter.add_child(counter)

	return
