extends Node2D
class_name LevelEditor

const LEVEL_SCENES := {
	1: "res://levels/level_1.tscn",
	2: "res://levels/level_2.tscn",
	3: "res://levels/level_3.tscn",
	4: "res://levels/level_4.tscn",
	5: "res://levels/level_5.tscn",
}

@export_range(1, 5) var level_number := 1
@export var grid_size := 16.0
@export var handle_size := 18.0

var _level_root: Node2D
var _camera: Camera2D
var _selected: Node2D
var _drag_offset := Vector2.ZERO
var _resize_mode := false
var _dragging := false
var _hud: Label


func _ready() -> void:
	_load_level()
	_create_camera()
	_create_hud()
	_load_layout_overrides()
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.keycode == KEY_S:
			_save_layout()
			get_viewport().set_input_as_handled()
		elif event.ctrl_pressed and event.keycode == KEY_D:
			_duplicate_selected()
			get_viewport().set_input_as_handled()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_5:
			level_number = event.keycode - KEY_0
			_load_level()
			_load_layout_overrides()
			_update_hud()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			_selected = null
			_dragging = false
			_resize_mode = false
			queue_redraw()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos := get_global_mouse_position()
		if event.pressed:
			_pick_node(world_pos)
		else:
			_finish_edit()
			_save_layout()

	if event is InputEventMouseMotion and _selected != null and _dragging:
		var world_pos := get_global_mouse_position()
		if _resize_mode:
			_resize_selected(world_pos)
		else:
			_selected.global_position = _snap(world_pos + _drag_offset)
		queue_redraw()
		_update_hud()


func _finish_edit() -> void:
	_selected = null
	_dragging = false
	_resize_mode = false
	queue_redraw()
	_update_hud()


func _duplicate_selected() -> void:
	if _selected == null or _selected.get_parent() == null:
		_update_hud("Select a block first, then Ctrl+D duplicate")
		return
	var copy := _selected.duplicate()
	copy.name = _unique_copy_name(_selected.name)
	copy.global_position = _snap(_selected.global_position + Vector2(grid_size * 2.0, grid_size * 2.0))
	_selected.get_parent().add_child(copy)
	copy.owner = _level_root
	_selected = copy
	_dragging = false
	_resize_mode = false
	queue_redraw()
	_save_layout()
	_update_hud("Duplicated: %s" % copy.name)


func _unique_copy_name(base_name: String) -> String:
	var clean_base := base_name
	if clean_base.contains("@"):
		clean_base = clean_base.get_slice("@", 0)
	var index := 1
	var candidate := "%s_Copy%d" % [clean_base, index]
	while _level_root.find_child(candidate, true, false) != null:
		index += 1
		candidate = "%s_Copy%d" % [clean_base, index]
	return candidate


func _draw() -> void:
	if _selected == null:
		return
	var rect := _node_rect(_selected)
	draw_rect(rect, Color(0.1, 0.55, 1.0, 0.25), false, 3.0)
	draw_rect(_handle_rect(rect), Color(1.0, 0.85, 0.15, 0.95), true)


func _load_level() -> void:
	if _level_root != null:
		_level_root.queue_free()
	_level_root = load(LEVEL_SCENES[level_number]).instantiate()
	add_child(_level_root)


func _create_camera() -> void:
	_camera = Camera2D.new()
	_camera.name = "EditorCamera"
	_camera.position = Vector2(960, 520)
	_camera.zoom = Vector2(0.75, 0.75)
	add_child(_camera)
	_camera.make_current()


func _create_hud() -> void:
	_hud = Label.new()
	_hud.name = "Help"
	_hud.position = Vector2(24, 24)
	_hud.text = ""
	_hud.add_theme_font_size_override("font_size", 18)
	add_child(_hud)


func _pick_node(world_pos: Vector2) -> void:
	_selected = null
	for node in _editable_nodes():
		var rect := _node_rect(node)
		if _handle_rect(rect).has_point(world_pos):
			_selected = node
			_resize_mode = true
			_dragging = true
			queue_redraw()
			return
		if rect.has_point(world_pos):
			_selected = node
			_resize_mode = false
			_dragging = true
			_drag_offset = node.global_position - world_pos
			queue_redraw()
			return
	_finish_edit()


func _editable_nodes() -> Array[Node2D]:
	var result: Array[Node2D] = []
	if _level_root == null:
		return result
	for node in _level_root.find_children("*", "", true, false):
		if node is Node2D and _is_editable(node):
			result.append(node)
	return result


func _is_editable(node: Node) -> bool:
	return node.has_method("set") and (
		"size" in node or "count" in node or "offset" in node or node is Marker2D
	)


func _node_rect(node: Node2D) -> Rect2:
	var size := _node_size(node)
	return Rect2(node.global_position - size * 0.5, size)


func _node_size(node: Node) -> Vector2:
	if "size" in node:
		return node.get("size")
	if "count" in node:
		return Vector2(float(node.get("count")) * 34.0, 58.0)
	return Vector2(40, 40)


func _handle_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position + rect.size - Vector2(handle_size, handle_size), Vector2(handle_size, handle_size))


func _resize_selected(world_pos: Vector2) -> void:
	if _selected == null or not ("size" in _selected):
		return
	var top_left := _selected.global_position - _node_size(_selected) * 0.5
	var new_size := _snap(world_pos - top_left)
	new_size.x = maxf(grid_size, new_size.x)
	new_size.y = maxf(grid_size, new_size.y)
	_selected.set("size", new_size)
	_selected.global_position = _snap(top_left + new_size * 0.5)


func _snap(value: Vector2) -> Vector2:
	if grid_size <= 0.0:
		return value
	return Vector2(roundf(value.x / grid_size) * grid_size, roundf(value.y / grid_size) * grid_size)


func _save_layout() -> void:
	var data := {}
	for node in _editable_nodes():
		data[node.name] = {
			"position": [node.global_position.x, node.global_position.y],
		}
		if "size" in node:
			var size: Vector2 = node.get("size")
			data[node.name]["size"] = [size.x, size.y]
		if "offset" in node:
			var offset: Vector2 = node.get("offset")
			data[node.name]["offset"] = [offset.x, offset.y]
		if "count" in node:
			data[node.name]["count"] = node.get("count")
	var file := FileAccess.open(_layout_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	_update_hud("Saved with Ctrl+S / mouse release")


func _load_layout_overrides() -> void:
	if not FileAccess.file_exists(_layout_path()):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_layout_path()))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for node in _editable_nodes():
		if not parsed.has(node.name):
			continue
		var entry: Dictionary = parsed[node.name]
		if entry.has("position"):
			node.global_position = Vector2(entry["position"][0], entry["position"][1])
		if entry.has("size") and "size" in node:
			node.set("size", Vector2(entry["size"][0], entry["size"][1]))
		if entry.has("offset") and "offset" in node:
			node.set("offset", Vector2(entry["offset"][0], entry["offset"][1]))
		if entry.has("count") and "count" in node:
			node.set("count", int(entry["count"]))


func _layout_path() -> String:
	return "res://levels/layout_overrides_level_%d.json" % level_number


func _update_hud(extra := "") -> void:
	var selected_text: String = _selected.name if _selected != null else "none"
	_hud.text = "UGC Level Editor | 1-5 switch level | drag block | drag yellow handle resize | Ctrl+S save\nLevel: %d  Selected: %s\n%s" % [level_number, selected_text, extra]
