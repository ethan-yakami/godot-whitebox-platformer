@tool
extends Node2D
class_name JumpArcGuide

@export var sync_with_player_defaults := true:
	set(value):
		sync_with_player_defaults = value
		_sync_player_defaults()
		queue_redraw()
@export_file("*.gd") var player_script_path := "res://scripts/player.gd":
	set(value):
		player_script_path = value
		_sync_player_defaults()
		queue_redraw()
@export var player_speed := 256.0:
	set(value):
		player_speed = value
		queue_redraw()
@export var jump_velocity := -775.0:
	set(value):
		jump_velocity = value
		queue_redraw()
@export var gravity := 1600.0:
	set(value):
		gravity = value
		queue_redraw()
@export var player_size := Vector2(48, 64):
	set(value):
		player_size = value
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
@export var show_player_samples := true:
	set(value):
		show_player_samples = value
		queue_redraw()
@export var player_sample_count := 5:
	set(value):
		player_sample_count = maxi(1, value)
		queue_redraw()
@export var show_labels := true:
	set(value):
		show_labels = value
		queue_redraw()
@export var normal_jump_color := Color(0.95, 0.2, 0.18, 0.85):
	set(value):
		normal_jump_color = value
		queue_redraw()
@export var fall_inertia_color := Color(0.2, 0.75, 0.35, 0.85):
	set(value):
		fall_inertia_color = value
		queue_redraw()
@export var player_box_fill_color := Color(0.0, 0.95, 1.0, 0.32):
	set(value):
		player_box_fill_color = value
		queue_redraw()
@export var player_box_outline_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		player_box_outline_color = value
		queue_redraw()


func _ready() -> void:
	_sync_player_defaults()
	queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	_sync_player_defaults()
	var horizontal_speed := player_speed * horizontal_speed_scale * float(direction)
	var normal_jump_points := _make_jump_points(horizontal_speed, jump_velocity, simulation_time)
	var fall_inertia_points := _make_jump_points(horizontal_speed, 0.0, fall_time)
	_draw_player_box(Vector2.ZERO, player_box_fill_color, player_box_outline_color, true)
	_draw_arc(normal_jump_points, normal_jump_color, "normal jump")
	_draw_arc(fall_inertia_points, fall_inertia_color, "fall / inertia")
	if show_player_samples:
		_draw_player_samples(normal_jump_points, normal_jump_color)
		_draw_player_samples(fall_inertia_points, fall_inertia_color)
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


func _draw_player_samples(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 2:
		return
	var stride := maxi(1, int(points.size() / player_sample_count))
	var drawn := 0
	for index in range(stride, points.size(), stride):
		if drawn >= player_sample_count:
			return
		var fill := Color(color.r, color.g, color.b, 0.12)
		var outline := Color(color.r, color.g, color.b, 0.55)
		_draw_player_box(points[index], fill, outline, false)
		drawn += 1


func _draw_player_box(
	center := Vector2.ZERO,
	fill_color := Color(0.0, 0.95, 1.0, 0.32),
	outline_color := Color(1.0, 1.0, 1.0, 1.0),
	is_origin_box := true
) -> void:
	var rect := Rect2(center - player_size * 0.5, player_size)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, outline_color, false, 4.0 if is_origin_box else 2.0)
	draw_line(Vector2(center.x - player_size.x * 0.5, center.y), Vector2(center.x + player_size.x * 0.5, center.y), outline_color, 2.0 if is_origin_box else 1.0)
	draw_line(Vector2(center.x, center.y - player_size.y * 0.5), Vector2(center.x, center.y + player_size.y * 0.5), outline_color, 2.0 if is_origin_box else 1.0)
	draw_circle(center, 6.0 if is_origin_box else 3.0, Color(1.0, 0.05, 0.05, 1.0) if is_origin_box else outline_color)
	if show_labels and is_origin_box:
		draw_string(ThemeDB.fallback_font, Vector2(player_size.x * 0.5 + 8, -8), "player center", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, player_box_outline_color)


func _sync_player_defaults() -> void:
	if not sync_with_player_defaults:
		return
	if player_script_path.is_empty():
		return
	if not ResourceLoader.exists(player_script_path):
		return
	var player_text := FileAccess.get_file_as_string(player_script_path)
	if player_text.is_empty():
		return
	var next_speed: Variant = _extract_float_default(player_text, "speed")
	var next_jump_velocity: Variant = _extract_float_default(player_text, "jump_velocity")
	var next_gravity: Variant = _extract_float_default(player_text, "gravity")
	if next_speed != null and not is_equal_approx(player_speed, float(next_speed)):
		player_speed = float(next_speed)
	if next_jump_velocity != null and not is_equal_approx(jump_velocity, float(next_jump_velocity)):
		jump_velocity = float(next_jump_velocity)
	if next_gravity != null and not is_equal_approx(gravity, float(next_gravity)):
		gravity = float(next_gravity)


func _extract_float_default(script_text: String, property_name: String) -> Variant:
	var regex := RegEx.new()
	var pattern := "(?:@export\\s+)?var\\s+" + property_name + "\\s*:=\\s*(-?\\d+(?:\\.\\d+)?)"
	if regex.compile(pattern) != OK:
		return null
	var result := regex.search(script_text)
	if result == null:
		return null
	return result.get_string(1).to_float()
