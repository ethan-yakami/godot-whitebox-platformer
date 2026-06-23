@tool
extends Area2D
class_name BouncePad

@export var size := Vector2(72, 18):
	set(value):
		size = value
		_rebuild()
@export var bounce_force := 760.0


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	var rect := ColorRect.new()
	rect.position = -size * 0.5
	rect.size = size
	rect.color = Color(0.2, 1.0, 0.35)
	add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	add_child(collision)


func _on_body_entered(body: Node) -> void:
	if body is Player and body.velocity.y >= 0.0:
		body.bounce(bounce_force)
