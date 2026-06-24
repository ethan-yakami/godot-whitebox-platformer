@tool
extends Area2D
class_name MovingSpike

@export var count := 3:
	set(value):
		count = maxi(1, value)
		_rebuild()
@export_enum("up", "down", "left", "right") var direction := "up":
	set(value):
		direction = value
		_rebuild()
@export var damage := 1
@export var offset := Vector2(128, 0):
	set(value):
		offset = value
		queue_redraw()
@export var speed := 128.0

var _origin := Vector2.ZERO
var _t := 0.0


func _ready() -> void:
	_rebuild()
	_origin = global_position
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if offset.length() <= 0.0:
		return
	_t += delta * speed / offset.length()
	var alpha := (sin(_t * TAU) + 1.0) * 0.5
	global_position = _origin.lerp(_origin + offset, alpha)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	_draw_dashed_line(Vector2.ZERO, offset, Color(0.35, 1.0, 0.45, 0.75), 2.0, 18.0, 10.0)
	draw_circle(Vector2.ZERO, 6.0, Color(0.25, 0.45, 0.85, 0.9))
	draw_circle(offset, 6.0, Color(1.0, 0.25, 0.2, 0.9))


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float, dash_length: float, gap_length: float) -> void:
	var travel := to - from
	var length := travel.length()
	if length <= 0.0:
		return
	var dir := travel / length
	var distance := 0.0
	while distance < length:
		var start := from + dir * distance
		var end := from + dir * minf(length, distance + dash_length)
		draw_line(start, end, color, width)
		distance += dash_length + gap_length


func _rebuild() -> void:
	if not is_inside_tree():
		return
	queue_redraw()
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
