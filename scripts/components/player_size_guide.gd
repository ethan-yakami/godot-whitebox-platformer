@tool
extends Node2D
class_name PlayerSizeGuide

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
@export var player_size := Vector2(48, 64):
	set(value):
		player_size = value
		queue_redraw()
@export var fill_color := Color(0.0, 0.95, 1.0, 0.28):
	set(value):
		fill_color = value
		queue_redraw()
@export var outline_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		outline_color = value
		queue_redraw()
@export var center_color := Color(1.0, 0.05, 0.05, 1.0):
	set(value):
		center_color = value
		queue_redraw()
@export var show_label := true:
	set(value):
		show_label = value
		queue_redraw()


func _ready() -> void:
	_sync_player_defaults()
	queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	_sync_player_defaults()
	var rect := Rect2(-player_size * 0.5, player_size)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, outline_color, false, 4.0)
	draw_line(Vector2(-player_size.x * 0.5, 0.0), Vector2(player_size.x * 0.5, 0.0), outline_color, 2.0)
	draw_line(Vector2(0.0, -player_size.y * 0.5), Vector2(0.0, player_size.y * 0.5), outline_color, 2.0)
	draw_circle(Vector2.ZERO, 6.0, center_color)
	if show_label:
		var text := "player size " + str(int(player_size.x)) + "x" + str(int(player_size.y))
		draw_string(ThemeDB.fallback_font, Vector2(player_size.x * 0.5 + 8.0, -8.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, outline_color)


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
	var next_size: Variant = _extract_vector2_default(player_text, "whitebox_size")
	if next_size != null and player_size != next_size:
		player_size = next_size


func _extract_vector2_default(script_text: String, property_name: String) -> Variant:
	var regex := RegEx.new()
	var pattern := "(?:@export\\s+)?var\\s+" + property_name + "\\s*:=\\s*Vector2\\(([-\\d.]+),\\s*([-\\d.]+)\\)"
	if regex.compile(pattern) != OK:
		return null
	var result := regex.search(script_text)
	if result == null:
		return null
	return Vector2(result.get_string(1).to_float(), result.get_string(2).to_float())
