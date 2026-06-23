@tool
extends Area2D
class_name Checkpoint

@export var size := Vector2(30, 96):
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
	rect.color = Color(1.0, 0.88, 0.25)
	add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	add_child(collision)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		GameState.set_checkpoint(global_position)
