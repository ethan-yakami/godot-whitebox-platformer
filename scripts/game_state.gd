extends Node

signal state_changed
signal health_changed(current: int, maximum: int)
signal checkpoint_changed(position: Vector2)
signal player_died(position: Vector2)

const PHASE_OUTBOUND := "outbound"
const PHASE_RETURN := "return"

var phase := PHASE_OUTBOUND
var current_level := 1
var has_legacy := false
var has_double_jump := false
var has_dash := false
var has_attack := false
var max_health := 3
var health := 3
var checkpoint_position := Vector2.ZERO
var ghost_positions: Array[Vector2] = []
var max_ghosts := 2


func reset_run(spawn_position: Vector2) -> void:
	phase = PHASE_OUTBOUND
	current_level = 1
	has_legacy = false
	has_double_jump = false
	has_dash = false
	has_attack = false
	max_health = 3
	health = max_health
	checkpoint_position = spawn_position
	ghost_positions.clear()
	state_changed.emit()
	health_changed.emit(health, max_health)
	checkpoint_changed.emit(checkpoint_position)


func set_checkpoint(position: Vector2) -> void:
	checkpoint_position = position
	heal_to_full()
	checkpoint_changed.emit(checkpoint_position)


func heal(amount: int) -> void:
	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)


func heal_to_full() -> void:
	health = max_health
	health_changed.emit(health, max_health)


func damage(amount: int, death_position: Vector2) -> bool:
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health <= 0:
		handle_death(death_position)
		return true
	return false


func handle_death(death_position: Vector2) -> void:
	if phase == PHASE_RETURN:
		ghost_positions.append(death_position)
		while ghost_positions.size() > max_ghosts:
			ghost_positions.pop_front()
	player_died.emit(death_position)
	heal_to_full()


func award_double_jump() -> void:
	has_double_jump = true
	state_changed.emit()


func award_attack() -> void:
	has_attack = true
	state_changed.emit()


func award_legacy() -> void:
	has_legacy = true
	has_dash = true
	max_health = 5
	health = max_health
	phase = PHASE_RETURN
	current_level = 5
	state_changed.emit()
	health_changed.emit(health, max_health)


func advance_level() -> void:
	if phase == PHASE_OUTBOUND:
		current_level += 1
	else:
		current_level -= 1
	state_changed.emit()


func is_victory() -> bool:
	return phase == PHASE_RETURN and has_legacy and current_level <= 1
