@tool
extends StaticBody2D
class_name CollapsePlatform

@export var size := Vector2(160, 28):
	set(value):
		size = value
		_rebuild()
@export var color := Color(1.0, 0.45, 0.75):
	set(value):
		color = value
		_rebuild()
@export var collapse_delay := 0.35

var _collapsing := false


func _ready() -> void:
	_rebuild()


func arm_trigger(size: Vector2) -> void:
	self.size = size
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
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

	var trigger := get_node_or_null("CollapseTrigger") as Area2D
	if trigger == null:
		trigger = Area2D.new()
		trigger.name = "CollapseTrigger"
		trigger.body_entered.connect(_on_body_entered)
		add_child(trigger)
	var trigger_collision := trigger.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if trigger_collision == null:
		trigger_collision = CollisionShape2D.new()
		trigger_collision.name = "CollisionShape2D"
		trigger.add_child(trigger_collision)
	var trigger_shape := trigger_collision.shape as RectangleShape2D
	if trigger_shape == null:
		trigger_shape = RectangleShape2D.new()
		trigger_collision.shape = trigger_shape
	trigger_shape.size = size + Vector2(0, 8)
	trigger_collision.position = Vector2(0, -4)


func _on_body_entered(body: Node) -> void:
	if Engine.is_editor_hint():
		return
	if _collapsing:
		return
	if body is Player:
		_collapsing = true
		modulate = Color(1.0, 0.65, 0.85, 0.8)
		await get_tree().create_timer(collapse_delay).timeout
		queue_free()
