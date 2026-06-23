@tool
extends Area2D
class_name Altar

signal activated(kind: String)

@export var altar_note := "Boss后交互获得传承"
@export var size := Vector2(70, 70):
	set(value):
		size = value
		_rebuild()

var _player_inside := false


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _player_inside and Input.is_action_just_pressed("attack_interact"):
		activated.emit("altar")


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		child.queue_free()
	var marker := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(8):
		points.append(Vector2(cos(TAU * i / 8.0), sin(TAU * i / 8.0)) * 44.0)
	marker.polygon = points
	marker.color = Color(0.25, 0.48, 0.9)
	add_child(marker)
	var goal := Polygon2D.new()
	var goal_points := PackedVector2Array()
	for i in range(20):
		goal_points.append(Vector2(cos(TAU * i / 20.0), sin(TAU * i / 20.0)) * 34.0)
	goal.position = Vector2(0, -76)
	goal.polygon = goal_points
	goal.color = Color(1.0, 0.82, 0.25)
	add_child(goal)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	add_child(collision)
	var label := Label.new()
	label.position = Vector2(-42, 46)
	label.text = "献祭石"
	add_child(label)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_inside = true


func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_inside = false
