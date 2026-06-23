@tool
extends Node2D
class_name StartViewBox

@export var size := Vector2(1120, 500):
	set(value):
		size = value
		queue_redraw()
@export var color := Color(0.0, 0.0, 0.0, 0.55):
	set(value):
		color = value
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), color, false, 3.0)
