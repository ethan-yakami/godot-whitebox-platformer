extends RefCounted
class_name InputLimiter

signal limits_changed

var limits := {}


func configure(new_limits: Dictionary) -> void:
	limits.clear()
	for key in new_limits.keys():
		limits[key] = int(new_limits[key])
	limits_changed.emit()


func can_use(action: String, cost := 1) -> bool:
	if not limits.has(action):
		return true
	return int(limits[action]) >= cost


func consume_action(action: String, cost := 1) -> bool:
	if not can_use(action, cost):
		return false
	if limits.has(action):
		limits[action] = maxi(0, int(limits[action]) - cost)
		limits_changed.emit()
	return true


func get_remaining(action: String) -> int:
	if not limits.has(action):
		return -1
	return int(limits[action])


func describe() -> String:
	if limits.is_empty():
		return "No limits"
	var parts: Array[String] = []
	for key in limits.keys():
		parts.append("%s:%d" % [key, int(limits[key])])
	return " ".join(parts)
