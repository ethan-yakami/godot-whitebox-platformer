extends CharacterBody2D
class_name Player

signal died(position: Vector2)
signal attacked
signal limit_denied(action: String)
signal void_recover

@export var speed := 256.0
@export var jump_velocity := -560.0
@export var dash_speed := 720.0
@export var dash_duration := 0.14
@export var dash_cooldown := 0.5
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12
@export var max_fall_speed := 900.0
@export var invincible_time := 0.7
@export var flash_timer := 0.08

var limiter: InputLimiter
var gravity := 1600.0
var _facing := 1
var _jump_count := 0
var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _dash_left := 0.0
var _dash_cooldown_left := 0.0
var _external_force := Vector2.ZERO
var _spawn_position := Vector2.ZERO
var _invincible_left := 0.0
var _flash_left := 0.0
var _move_press_allowed := {
	"move_left": false,
	"move_right": false,
}
var _last_safe_position := Vector2.ZERO

@onready var body: ColorRect = $Body


func _ready() -> void:
	_spawn_position = global_position
	_last_safe_position = global_position


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack_interact"):
		if GameState.has_attack and (limiter == null or limiter.consume_action("attack_interact")):
			attacked.emit()

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_left = jump_buffer_time

	if Input.is_action_just_pressed("dash") and GameState.has_dash:
		perform_dash()

	_update_timers(delta)
	_apply_movement(delta)
	move_and_slide()
	_external_force = Vector2.ZERO
	if is_on_floor():
		_last_safe_position = global_position

	if global_position.y > 980:
		var died_now := take_damage(2)
		if not died_now:
			global_position = _last_safe_position
			velocity = Vector2.ZERO
			void_recover.emit()


func _update_timers(delta: float) -> void:
	_jump_buffer_left = maxf(0.0, _jump_buffer_left - delta)
	_dash_left = maxf(0.0, _dash_left - delta)
	_dash_cooldown_left = maxf(0.0, _dash_cooldown_left - delta)
	_invincible_left = maxf(0.0, _invincible_left - delta)
	_flash_left = maxf(0.0, _flash_left - delta)
	if _invincible_left > 0.0 and _flash_left <= 0.0:
		_flash_left = flash_timer
		body.visible = not body.visible
	elif _invincible_left <= 0.0:
		body.visible = true
	if is_on_floor():
		_coyote_left = coyote_time
		_jump_count = 0
	else:
		_coyote_left = maxf(0.0, _coyote_left - delta)


func _apply_movement(delta: float) -> void:
	var input_dir := 0
	if Input.is_action_just_pressed("move_left"):
		_move_press_allowed["move_left"] = _can_spend_move("move_left")
	if Input.is_action_just_pressed("move_right"):
		_move_press_allowed["move_right"] = _can_spend_move("move_right")
	if Input.is_action_just_released("move_left"):
		_move_press_allowed["move_left"] = false
	if Input.is_action_just_released("move_right"):
		_move_press_allowed["move_right"] = false

	if Input.is_action_pressed("move_left") and bool(_move_press_allowed["move_left"]):
		input_dir -= 1
	if Input.is_action_pressed("move_right") and bool(_move_press_allowed["move_right"]):
		input_dir += 1

	if input_dir != 0:
		_facing = input_dir
		velocity.x = input_dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 8.0 * delta)

	if _dash_left > 0.0:
		velocity.x = _facing * dash_speed
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	if _jump_buffer_left > 0.0:
		_try_jump()

	velocity += _external_force


func _can_spend_move(action: String) -> bool:
	if limiter == null:
		return true
	if not limiter.can_use(action):
		limit_denied.emit(action)
		return false
	return limiter.consume_action(action)


func _try_jump() -> void:
	var can_ground_jump := is_on_floor() or _coyote_left > 0.0
	var can_double_jump := GameState.has_double_jump and _jump_count < 1
	if not can_ground_jump and not can_double_jump:
		return

	var cost := 1
	if not can_ground_jump:
		cost = 2
	if limiter != null and not limiter.consume_action("jump", cost):
		limit_denied.emit("jump")
		return

	velocity.y = jump_velocity
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	if can_ground_jump:
		_jump_count = 0
	else:
		_jump_count += 1


func perform_dash() -> void:
	if _dash_cooldown_left > 0.0:
		return
	if limiter != null and not limiter.consume_action("dash"):
		limit_denied.emit("dash")
		return
	_dash_left = dash_duration
	_dash_cooldown_left = dash_cooldown


func add_force(force: Vector2) -> void:
	_external_force += force


func bounce(force: float) -> void:
	velocity.y = -absf(force)


func take_damage(amount: int) -> bool:
	if _invincible_left > 0.0:
		return false
	_invincible_left = invincible_time
	_flash_left = flash_timer
	if GameState.damage(amount, global_position):
		died.emit(global_position)
		return true
	return false


func respawn_at(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	_dash_left = 0.0
	_dash_cooldown_left = 0.0
	_jump_buffer_left = 0.0
	_invincible_left = 0.0
	body.visible = true
	_last_safe_position = position


func set_whitebox_color(color: Color) -> void:
	body.color = color
