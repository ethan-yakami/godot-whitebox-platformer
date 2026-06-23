extends Node2D

const PlayerSceneScript := preload("res://scripts/player.gd")
const HazardScript := preload("res://scripts/hazard.gd")
const InteractableScript := preload("res://scripts/interactable.gd")
const EnemyScript := preload("res://scripts/enemy.gd")
const GhostScript := preload("res://scripts/ghost.gd")
const MovingPlatformScript := preload("res://scripts/moving_platform.gd")
const CollapsePlatformScript := preload("res://scripts/collapse_platform.gd")
const HudScript := preload("res://scripts/hud.gd")
const LevelDataScript := preload("res://scripts/level_data.gd")

const LEVEL_SCENES := {
	1: "res://levels/level_1.tscn",
	2: "res://levels/level_2.tscn",
	3: "res://levels/level_3.tscn",
	4: "res://levels/level_4.tscn",
	5: "res://levels/level_5.tscn",
}

var player: Player
var hud: Hud
var limiter := InputLimiter.new()
var level_root: Node2D
var current_level_scene: Node2D
var camera: Camera2D
var current_level_data := {}
var paused := false
var defeated_bosses := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_root = Node2D.new()
	level_root.name = "LevelRoot"
	add_child(level_root)
	player = _create_player()
	add_child(player)
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()
	hud = HudScript.new()
	add_child(hud)
	hud.resume_requested = Callable(self, "set_pause").bind(false)
	hud.load_checkpoint_requested = Callable(self, "load_checkpoint")
	hud.restart_level_requested = Callable(self, "restart_current_level")
	hud.restart_run_requested = Callable(self, "restart_run")
	player.limiter = limiter
	player.died.connect(_on_player_died)
	player.attacked.connect(_on_player_attacked)
	player.limit_denied.connect(_on_limit_denied)
	player.void_recover.connect(_on_void_recover)
	GameState.player_died.connect(_on_state_player_died)
	GameState.health_changed.connect(_refresh_hud)
	GameState.state_changed.connect(_refresh_hud)
	GameState.reset_run(Vector2(96, 472))
	load_level(1)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		set_pause(not paused)
	if Input.is_action_just_pressed("load_checkpoint"):
		load_checkpoint()
	if Input.is_action_just_pressed("restart"):
		if Input.is_key_pressed(KEY_SHIFT):
			restart_run()
		else:
			restart_current_level()
	if not paused:
		_refresh_hud()


func load_level(level_number: int) -> void:
	GameState.current_level = clampi(level_number, 1, 5)
	current_level_data = LevelDataScript.get_level(GameState.current_level)
	for child in level_root.get_children():
		child.queue_free()
	var scene_path: String = LEVEL_SCENES[GameState.current_level]
	current_level_scene = load(scene_path).instantiate()
	level_root.add_child(current_level_scene)
	_wire_level_scene(current_level_scene)
	limiter.configure(LevelDataScript.get_limits(GameState.current_level, GameState.phase))
	var spawn := _get_level_spawn()
	player.respawn_at(spawn)
	GameState.set_checkpoint(_get_checkpoint_position())
	_spawn_existing_ghosts()
	_refresh_hud()


func _wire_level_scene(root: Node) -> void:
	for node in root.find_children("*", "", true, false):
		if node.has_signal("reached"):
			node.reached.connect(_on_exit_entered)
		elif node.has_signal("activated"):
			node.activated.connect(_on_stone_activated)
		elif node is Enemy:
			node.player = player
			node.defeated.connect(_on_enemy_defeated)


func set_pause(value: bool) -> void:
	paused = value
	get_tree().paused = paused
	hud.set_paused(paused)


func restart_run() -> void:
	set_pause(false)
	GameState.reset_run(Vector2(96, 472))
	defeated_bosses.clear()
	hud.show_message("整轮已重开")
	load_level(1)


func restart_current_level() -> void:
	set_pause(false)
	if GameState.current_level == 5:
		defeated_bosses.erase("legacy_boss")
	load_level(GameState.current_level)
	hud.show_message("当前关已重开，限制次数已重置")
	_refresh_hud()


func _get_level_spawn() -> Vector2:
	var spawn_marker := current_level_scene.find_child("SpawnPoint", true, false)
	var spawn: Vector2 = spawn_marker.global_position if spawn_marker != null else Vector2(96, 472)
	if GameState.phase == GameState.PHASE_RETURN:
		var return_marker := current_level_scene.find_child("ReturnSpawnPoint", true, false)
		var exit_marker := current_level_scene.find_child("ExitGate", true, false)
		var exit_position: Vector2 = return_marker.global_position if return_marker != null else (exit_marker.global_position if exit_marker != null else spawn)
		return exit_position + Vector2(-120, 0)
	return spawn


func load_checkpoint() -> void:
	set_pause(false)
	player.respawn_at(GameState.checkpoint_position)
	GameState.heal_to_full()
	hud.show_message("已读档到最近路灯，限制次数不重置")
	_refresh_hud()


func _get_checkpoint_position() -> Vector2:
	var checkpoint := current_level_scene.find_child("Checkpoint", true, false)
	return checkpoint.global_position if checkpoint != null else _get_level_spawn()


func _create_player() -> Player:
	var node := PlayerSceneScript.new()
	node.name = "Player"
	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(48, 64)
	body.position = Vector2(-24, -64)
	body.color = Color(0.2, 0.55, 1.0)
	node.add_child(body)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, 64)
	shape.shape = rect
	shape.position = Vector2(0, -32)
	node.add_child(shape)
	return node


func _add_rect_body(node_name: String, pos: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = pos
	var rect := ColorRect.new()
	rect.size = size
	rect.color = color
	body.add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	body.add_child(collision)
	level_root.add_child(body)
	return body


func _add_start_view_box(box: Array) -> void:
	var frame := Line2D.new()
	frame.name = "StartViewBox"
	frame.width = 3.0
	frame.default_color = Color.BLACK
	var x := float(box[0])
	var y := float(box[1])
	var w := float(box[2])
	var h := float(box[3])
	frame.points = PackedVector2Array([
		Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h),
		Vector2(x, y + h), Vector2(x, y),
	])
	level_root.add_child(frame)


func _add_spike_strip(pos: Vector2, count: int, direction: String) -> void:
	var width := 34.0
	var height := 58.0
	for i in range(count):
		var area := HazardScript.new()
		area.name = "Spike"
		area.damage = 1
		area.position = pos + Vector2(i * width, 0)
		var polygon := Polygon2D.new()
		var points := PackedVector2Array()
		match direction:
			"down":
				points = PackedVector2Array([Vector2(0, 0), Vector2(width, 0), Vector2(width * 0.5, height)])
			"right":
				points = PackedVector2Array([Vector2(0, 0), Vector2(height, width * 0.5), Vector2(0, width)])
			"left":
				points = PackedVector2Array([Vector2(height, 0), Vector2(0, width * 0.5), Vector2(height, width)])
			_:
				points = PackedVector2Array([Vector2(0, height), Vector2(width, height), Vector2(width * 0.5, 0)])
		polygon.polygon = points
		polygon.color = Color(0.25, 0.45, 0.85)
		area.add_child(polygon)
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(width, height) if direction != "right" and direction != "left" else Vector2(height, width)
		collision.shape = shape
		collision.position = shape.size * 0.5
		area.add_child(collision)
		level_root.add_child(area)


func _add_hazard(pos: Vector2, size: Vector2, damage: int, color: Color) -> Hazard:
	var area := HazardScript.new()
	area.name = "Hazard"
	area.position = pos
	area.damage = damage
	var rect := ColorRect.new()
	rect.size = size
	rect.color = color
	area.add_child(rect)
	area.add_child(_make_area_shape(size, size * 0.5))
	level_root.add_child(area)
	return area


func _add_force_zone(pos: Vector2, size: Vector2, force: Vector2) -> Hazard:
	var area := HazardScript.new()
	area.name = "River"
	area.position = pos
	area.damage = 0
	area.push_force = force
	var rect := ColorRect.new()
	rect.size = size
	rect.color = Color(1.0, 0.86, 0.42, 0.55)
	area.add_child(rect)
	area.add_child(_make_area_shape(size, size * 0.5))
	level_root.add_child(area)
	return area


func _add_bounce_pad(pos: Vector2) -> Hazard:
	var area := HazardScript.new()
	area.name = "BouncePad"
	area.position = pos
	area.damage = 0
	area.bounce_force = 760.0
	var rect := ColorRect.new()
	rect.size = Vector2(72, 18)
	rect.position = Vector2(-36, -9)
	rect.color = Color(0.2, 1.0, 0.35)
	area.add_child(rect)
	area.add_child(_make_area_shape(Vector2(72, 18)))
	level_root.add_child(area)
	return area


func _add_collapse_platform(pos: Vector2, size: Vector2) -> CollapsePlatform:
	var body := CollapsePlatformScript.new()
	body.name = "CollapsePlatform"
	body.position = pos
	var rect := ColorRect.new()
	rect.size = size
	rect.color = Color(1.0, 0.45, 0.75)
	body.add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	body.add_child(collision)
	body.arm_trigger(size)
	level_root.add_child(body)
	return body


func _add_interactable(kind: String, pos: Vector2, size: Vector2, color: Color) -> Interactable:
	var item := InteractableScript.new()
	item.name = kind.capitalize()
	item.kind = kind
	item.position = pos
	var rect := ColorRect.new()
	rect.size = size
	rect.position = -size * 0.5
	rect.color = color
	item.add_child(rect)
	item.add_child(_make_area_shape(size))
	item.interacted.connect(_on_interacted)
	level_root.add_child(item)
	return item


func _add_stone(pos: Vector2, kind: String) -> Node2D:
	if kind == "altar":
		_add_goal_marker(pos + Vector2(0, -70))
	else:
		_add_interactable("stone", pos, Vector2(62, 62), Color(0.25, 0.48, 0.9, 0.35))
	var marker := _add_round_marker(pos, Color(0.25, 0.48, 0.9), 42.0)
	marker.name = "Stone"
	var label := Label.new()
	label.position = pos + Vector2(-42, 46)
	label.text = "献祭石" if kind == "altar" else "石碑"
	label.add_theme_font_size_override("font_size", 16)
	level_root.add_child(label)
	return marker


func _add_goal_marker(pos: Vector2) -> Node2D:
	return _add_round_marker(pos, Color(1.0, 0.82, 0.25), 34.0)


func _add_round_marker(pos: Vector2, color: Color, radius: float) -> Node2D:
	var node := Node2D.new()
	node.name = "RoundMarker"
	node.position = pos
	var circle := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(20):
		var a := TAU * float(i) / 20.0
		points.append(Vector2(cos(a), sin(a)) * radius)
	circle.polygon = points
	circle.color = color
	node.add_child(circle)
	level_root.add_child(node)
	return node


func _add_exit(pos: Vector2) -> Area2D:
	var exit := Area2D.new()
	exit.name = "Exit"
	exit.position = pos
	_add_goal_marker(pos + Vector2(30, -80))
	var rect := ColorRect.new()
	rect.size = Vector2(48, 96)
	rect.position = Vector2(-24, -48)
	rect.color = Color(0.0, 0.9, 0.25, 0.75)
	exit.add_child(rect)
	exit.add_child(_make_area_shape(Vector2(48, 96)))
	exit.body_entered.connect(_on_exit_entered)
	level_root.add_child(exit)
	return exit


func _add_hint(pos: Vector2, text: String) -> Label:
	var label := Label.new()
	label.name = "Hint"
	label.position = pos
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.modulate = Color(0.95, 0.95, 0.95)
	level_root.add_child(label)
	return label


func _add_moving_platform(pos: Vector2, size: Vector2, offset: Vector2) -> MovingPlatform:
	var body := MovingPlatformScript.new()
	body.name = "MovingPlatform"
	body.position = pos
	body.offset = offset
	var rect := ColorRect.new()
	rect.size = size
	rect.color = Color(0.95, 0.55, 0.18)
	body.add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	body.add_child(collision)
	level_root.add_child(body)
	return body


func _add_enemy(pos: Vector2, is_ghost := false) -> Enemy:
	var enemy: Enemy = GhostScript.new() if is_ghost else EnemyScript.new()
	enemy.name = "Ghost" if is_ghost else "Monster"
	enemy.position = pos
	enemy.player = player
	enemy.defeated.connect(_on_enemy_defeated)
	var rect := ColorRect.new()
	rect.size = Vector2(48, 56)
	rect.position = Vector2(-24, -56)
	rect.color = Color(0.8, 0.0, 0.0) if not is_ghost else Color(0.45, 0.7, 1.0, 0.65)
	enemy.add_child(rect)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 56)
	collision.shape = shape
	collision.position = Vector2(0, -28)
	enemy.add_child(collision)
	var touch := Area2D.new()
	touch.name = "TouchDamage"
	touch.add_child(_make_area_shape(Vector2(60, 60), Vector2.ZERO))
	touch.body_entered.connect(enemy._on_touch)
	enemy.add_child(touch)
	level_root.add_child(enemy)
	return enemy


func _add_boss(pos: Vector2, boss_id: String) -> Enemy:
	var boss := _add_enemy(pos, false)
	boss.name = boss_id
	boss.health = 10
	boss.scale = Vector2(1.6, 1.6)
	boss.speed = 60.0
	return boss


func _make_area_shape(size: Vector2, offset := Vector2.ZERO) -> CollisionShape2D:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = offset
	return collision


func _on_interacted(kind: String, node: Node) -> void:
	match kind:
		"berry":
			GameState.heal(1)
			node.queue_free()
		"altar":
			if GameState.current_level == 5 and GameState.phase == GameState.PHASE_OUTBOUND:
				if _boss_defeated("legacy_boss"):
					award_legacy()
					load_level(5)
				else:
					hud.show_message("需要先击败 Boss 才能获得传承")
		"checkpoint":
			GameState.set_checkpoint(node.global_position)


func _on_stone_activated(kind: String) -> void:
	if kind == "altar":
		if GameState.current_level == 5 and GameState.phase == GameState.PHASE_OUTBOUND:
			if _boss_defeated("legacy_boss"):
				award_legacy()
				load_level(5)
			else:
				hud.show_message("需要先击败 Boss 才能获得传承")
	elif GameState.current_level == 4 and not GameState.has_attack:
		GameState.award_attack()
		hud.show_message("石碑：已解锁攻击键 J")


func _handle_exit() -> void:
	if GameState.phase == GameState.PHASE_OUTBOUND:
		if GameState.current_level == 1:
			award_double_jump()
		if GameState.current_level < 5:
			load_level(GameState.current_level + 1)
		else:
			award_legacy()
			load_level(5)
	else:
		if GameState.current_level > 1:
			load_level(GameState.current_level - 1)
		else:
			hud.help_label.text = "胜利：携带传承回到起点"


func _on_exit_entered(body: Node) -> void:
	if body is Player:
		_handle_exit()


func award_double_jump() -> void:
	GameState.award_double_jump()


func award_legacy() -> void:
	GameState.award_legacy()


func _on_player_died(_position: Vector2) -> void:
	pass


func _on_state_player_died(_death_position: Vector2) -> void:
	spawn_ghost(_death_position)
	player.respawn_at(GameState.checkpoint_position)
	hud.show_message("死亡：已回到最近路灯" + ("，生成残影" if GameState.phase == GameState.PHASE_RETURN else ""))
	_refresh_hud()


func spawn_ghost(position: Vector2) -> void:
	if GameState.phase != GameState.PHASE_RETURN:
		return
	_add_enemy(position, true)


func _spawn_existing_ghosts() -> void:
	if GameState.phase != GameState.PHASE_RETURN:
		return
	for pos in GameState.ghost_positions:
		spawn_ghost(pos)


func _on_player_attacked() -> void:
	for node in level_root.get_children():
		if node is Enemy and player.global_position.distance_to(node.global_position) <= 96.0:
			node.hit(2)


func _on_enemy_defeated(enemy: Enemy) -> void:
	defeated_bosses[enemy.name] = true
	if enemy.name == "legacy_boss":
		limiter.configure({})
		hud.show_message("Boss已击败：一周目限制解除，去献祭石")
		return
	hud.show_message("%s 已击败" % enemy.name)


func _on_limit_denied(action: String) -> void:
	hud.show_message("%s 次数耗尽" % action)


func _on_void_recover() -> void:
	hud.show_message("掉落：扣 2 血并回到最近安全位置")


func _boss_defeated(boss_id: String) -> bool:
	return bool(defeated_bosses.get(boss_id, false))


func _refresh_hud(_a = null, _b = null) -> void:
	if hud == null:
		return
	hud.update_debug(GameState.current_level, current_level_data.get("title", ""), limiter)
