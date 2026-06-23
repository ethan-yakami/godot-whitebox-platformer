@tool
extends Area2D
class_name ExitGate

signal reached(body: Node)

@export var size := Vector2(48, 96):
	set(value):
		size = value
		_rebuild()


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
	rect.color = Color(0.0, 0.9, 0.25, 0.75)
	add_child(rect)
	var goal := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(20):
		points.append(Vector2(cos(TAU * i / 20.0), sin(TAU * i / 20.0)) * 34.0)
	goal.position = Vector2(30, -80)
	goal.polygon = points
	goal.color = Color(1.0, 0.82, 0.25)
	add_child(goal)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	add_child(collision)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		reached.emit(body)
