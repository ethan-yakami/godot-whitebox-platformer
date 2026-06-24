extends CanvasLayer
class_name Hud

var health_label: Label
var state_label: Label
var limits_label: Label
var help_label: Label
var pause_panel: Panel
var rules_panel: Panel
var legend_panel: Panel
var resume_requested: Callable
var load_checkpoint_requested: Callable
var restart_level_requested: Callable
var restart_run_requested: Callable


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	health_label = _make_label(Vector2(16, 12), 18)
	state_label = _make_label(Vector2(16, 40), 16)
	limits_label = _make_label(Vector2(16, 68), 16)
	help_label = _make_label(Vector2(16, 660), 14)
	help_label.text = "A/D移动 H跳跃 Space冲刺 J攻击/交互 Esc暂停 R重开 1-5跳关 | 白盒原型"
	pause_panel = Panel.new()
	pause_panel.visible = false
	pause_panel.position = Vector2(430, 220)
	pause_panel.size = Vector2(460, 280)
	add_child(pause_panel)
	var pause_text := Label.new()
	pause_text.position = Vector2(24, 18)
	pause_text.size = Vector2(400, 78)
	pause_text.text = "暂停\nEsc / Resume 继续\n读档不重置限制；重开本关会重置当前关限制"
	pause_panel.add_child(pause_text)
	_add_pause_button("Resume", Vector2(24, 96), "_on_resume_pressed")
	_add_pause_button("Load Checkpoint", Vector2(24, 136), "_on_load_checkpoint_pressed")
	_add_pause_button("Restart Level", Vector2(24, 176), "_on_restart_level_pressed")
	_add_pause_button("Restart Run", Vector2(24, 216), "_on_restart_run_pressed")
	_build_rules_panel()
	_build_legend_panel()


func _make_label(pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label


func _add_pause_button(text: String, pos: Vector2, method: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(190, 32)
	button.pressed.connect(Callable(self, method))
	pause_panel.add_child(button)


func _build_rules_panel() -> void:
	rules_panel = Panel.new()
	rules_panel.position = Vector2(910, 12)
	rules_panel.size = Vector2(340, 190)
	add_child(rules_panel)
	var text := Label.new()
	text.position = Vector2(12, 10)
	text.size = Vector2(310, 170)
	text.text = "规则\n1. 去程到第五关拿传承\n2. 返程带传承回起点\n3. 每关限制按键次数\n4. 返程死亡生成最多2个残影\n5. L读档，R重开本关，Shift+R重开整轮"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules_panel.add_child(text)


func _build_legend_panel() -> void:
	legend_panel = Panel.new()
	legend_panel.position = Vector2(910, 520)
	legend_panel.size = Vector2(340, 180)
	add_child(legend_panel)
	var text := Label.new()
	text.position = Vector2(12, 10)
	text.size = Vector2(312, 160)
	text.text = "操作 / 图例\nA/D 左右移动 | H 跳跃 | Space 冲刺 | J 攻击/交互\nL 读档 | R 重开当前关 | Shift+R 重开整轮\nGM 1-5 直跳关卡\n蓝色矩形：玩家\n灰色平台：安全落脚\n粉色平台：塌陷平台\n浅黄区域：水流/危险槽\n蓝色尖刺：伤害 | 黄色竖条：存档点"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend_panel.add_child(text)


func update_debug(level_number: int, level_title: String, limiter: InputLimiter) -> void:
	health_label.text = "HP %d/%d" % [GameState.health, GameState.max_health]
	state_label.text = "关卡 %d %s | 阶段:%s | 传承:%s | 二段跳:%s | 攻击:%s | 冲刺:%s | 残影:%d" % [
		level_number,
		level_title,
		GameState.phase,
		str(GameState.has_legacy),
		str(GameState.has_double_jump),
		str(GameState.has_attack),
		str(GameState.has_dash),
		GameState.ghost_positions.size(),
	]
	limits_label.text = "限制: %s" % limiter.describe()


func show_message(message: String) -> void:
	help_label.text = message


func set_paused(paused: bool) -> void:
	pause_panel.visible = paused


func _on_resume_pressed() -> void:
	if resume_requested.is_valid():
		resume_requested.call()


func _on_load_checkpoint_pressed() -> void:
	if load_checkpoint_requested.is_valid():
		load_checkpoint_requested.call()


func _on_restart_level_pressed() -> void:
	if restart_level_requested.is_valid():
		restart_level_requested.call()


func _on_restart_run_pressed() -> void:
	if restart_run_requested.is_valid():
		restart_run_requested.call()
