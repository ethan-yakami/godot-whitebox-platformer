@tool
extends Area2D
class_name SpikeStrip

@export var count := 3:
	set(value):
		count = maxi(1, value)
		_rebuild()
@export_enum("up", "down", "left", "right") var direction := "up":
	set(value):
		direction = value
		_rebuild()
@export var damage := 1


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	for i in range(count):
		var width := 34.0
		var height := 58.0
		var polygon := Polygon2D.new()
		match direction:
			"down":
				polygon.polygon = PackedVector2Array([Vector2(0, 0), Vector2(width, 0), Vector2(width * 0.5, height)])
				polygon.position = Vector2(i * width, 0)
			"right":
				polygon.polygon = PackedVector2Array([Vector2(0, 0), Vector2(height, width * 0.5), Vector2(0, width)])
				polygon.position = Vector2(0, i * width)
			"left":
				polygon.polygon = PackedVector2Array([Vector2(height, 0), Vector2(0, width * 0.5), Vector2(height, width)])
				polygon.position = Vector2(0, i * width)
			_:
				polygon.polygon = PackedVector2Array([Vector2(0, height), Vector2(width, height), Vector2(width * 0.5, 0)])
				polygon.position = Vector2(i * width, 0)
		polygon.color = Color(0.25, 0.45, 0.85)
		add_child(polygon)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(count * 34.0, 58.0) if direction == "up" or direction == "down" else Vector2(58.0, count * 34.0)
	collision.shape = shape
	collision.position = shape.size * 0.5
	add_child(collision)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_damage(damage)
