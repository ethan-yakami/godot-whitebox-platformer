@tool
extends StaticBody2D
class_name WhiteboxPlatform

@export var size := Vector2(240, 32):
	set(value):
		size = value
		_rebuild()
@export var color := Color(0.72, 0.72, 0.72):
	set(value):
		color = value
		_rebuild()


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	var rect := ColorRect.new()
	rect.size = size
	rect.color = color
	add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	add_child(collision)
