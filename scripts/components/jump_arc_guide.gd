@tool
extends Node2D
class_name JumpArcGuide

@export var player_speed := 256.0:
	set(value):
		player_speed = value
		queue_redraw()
@export var jump_velocity := -640.0:
	set(value):
		jump_velocity = value
		queue_redraw()
@export var gravity := 1600.0:
	set(value):
		gravity = value
		queue_redraw()
@export var direction := 1:
	set(value):
		direction = 1 if value >= 0 else -1
		queue_redraw()
@export var simulation_time := 0.95:
	set(value):
		simulation_time = maxf(0.1, value)
		queue_redraw()
@export var fall_time := 0.85:
	set(value):
		fall_time = maxf(0.1, value)
		queue_redraw()
@export var sample_step := 0.05:
	set(value):
		sample_step = clampf(value, 0.02, 0.2)
		queue_redraw()
@export var horizontal_speed_scale := 1.0:
	set(value):
		horizontal_speed_scale = maxf(0.0, value)
		queue_redraw()
@export var show_labels := true:
	set(value):
		show_labels = value
		queue_redraw()
@export var normal_jump_color := Color(0.95, 0.2, 0.18, 0.85):
	set(value):
		normal_jump_color = value
		queue_redraw()
@export var double_jump_color := Color(0.25, 0.45, 1.0, 0.85):
	set(value):
		double_jump_color = value
		queue_redraw()
@export var fall_inertia_color := Color(0.2, 0.75, 0.35, 0.85):
	set(value):
		fall_inertia_color = value
		queue_redraw()


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var horizontal_speed := player_speed * horizontal_speed_scale * float(direction)
	_draw_arc(_make_jump_points(horizontal_speed, jump_velocity, simulation_time), normal_jump_color, "normal jump")
	_draw_arc(_make_jump_points(horizontal_speed, jump_velocity * 0.92, simulation_time * 1.18), double_jump_color, "double jump")
	_draw_arc(_make_jump_points(horizontal_speed, 0.0, fall_time), fall_inertia_color, "fall / inertia")
	_draw_landing_band(horizontal_speed)


func _make_jump_points(horizontal_speed: float, start_velocity_y: float, duration: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var t := 0.0
	while t <= duration:
		var x := horizontal_speed * t
		var y := start_velocity_y * t + 0.5 * gravity * t * t
		points.append(Vector2(x, y))
		t += sample_step
	return points


func _draw_arc(points: PackedVector2Array, color: Color, label: String) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, color, 3.0, true)
	if show_labels:
		var font := ThemeDB.fallback_font
		var end := points[points.size() - 1]
		draw_string(font, end + Vector2(10, -8), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, color)


func _draw_landing_band(horizontal_speed: float) -> void:
	var min_x := absf(horizontal_speed) * 0.62
	var max_x := absf(horizontal_speed) * 0.95
	var sign := float(direction)
	var y := 8.0
	draw_line(Vector2(min_x * sign, y), Vector2(max_x * sign, y), Color(1.0, 0.85, 0.15, 0.9), 5.0)
	if show_labels:
		draw_string(ThemeDB.fallback_font, Vector2(max_x * sign + 10.0 * sign, y + 18.0), "comfort landing", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(1.0, 0.85, 0.15, 0.9))
