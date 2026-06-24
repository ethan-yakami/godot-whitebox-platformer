@tool
extends AnimatableBody2D
class_name MovingPlatform

@export var size := Vector2(160, 28):
	set(value):
		size = value
		_rebuild()
@export var color := Color(0.95, 0.55, 0.18):
	set(value):
		color = value
		_rebuild()
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
	draw_line(Vector2.ZERO, offset, Color(0.95, 0.55, 0.18, 0.75), 3.0)
	draw_circle(Vector2.ZERO, 6.0, Color(0.2, 0.55, 1.0, 0.85))
	draw_circle(offset, 6.0, Color(1.0, 0.25, 0.2, 0.85))


func _rebuild() -> void:
	if not is_inside_tree():
		return
	queue_redraw()
	var body := get_node_or_null("Visual") as ColorRect
	if body == null:
		body = ColorRect.new()
		body.name = "Visual"
		add_child(body)
	body.size = size
	body.position = -size * 0.5
	body.color = color

	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		add_child(collision)
	var shape := collision.shape as RectangleShape2D
	if shape == null:
		shape = RectangleShape2D.new()
		collision.shape = shape
	shape.size = size
