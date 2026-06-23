@tool
extends Area2D
class_name WaterZone

@export var size := Vector2(600, 120):
	set(value):
		size = value
		_rebuild()
@export var push_force := Vector2(135, 0)


func _ready() -> void:
	_rebuild()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for body in get_overlapping_bodies():
		if body is Player:
			body.add_force(push_force)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	var rect := ColorRect.new()
	rect.size = size
	rect.color = Color(1.0, 0.86, 0.42, 0.55)
	add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	add_child(collision)
