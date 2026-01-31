extends Area2D

class_name sword

var mouse_position

func _process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	look_at(mouse_position)
