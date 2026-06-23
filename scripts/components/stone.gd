@tool
extends Area2D
class_name Stone

signal activated(kind: String)

@export_enum("stone", "altar") var kind := "stone":
	set(value):
		kind = value
		_rebuild()
@export var size := Vector2(62, 62):
	set(value):
		size = value
		_rebuild()


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


var _player_inside := false


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _player_inside and Input.is_action_just_pressed("attack_interact"):
		activated.emit(kind)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	var marker := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(8):
		points.append(Vector2(cos(TAU * i / 8.0), sin(TAU * i / 8.0)) * 42.0)
	marker.polygon = points
	marker.color = Color(0.25, 0.48, 0.9)
	add_child(marker)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	add_child(collision)
	var label := Label.new()
	label.position = Vector2(-42, 46)
	label.text = "献祭石" if kind == "altar" else "石碑"
	add_child(label)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_inside = true


func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_inside = false
