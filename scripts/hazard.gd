extends Area2D
class_name Hazard

@export var damage := 1
@export var push_force := Vector2.ZERO
@export var bounce_force := 0.0
@export var one_shot := false

var _used := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if push_force == Vector2.ZERO:
		return
	for body in get_overlapping_bodies():
		if body is Player:
			body.add_force(push_force)


func _on_body_entered(body: Node) -> void:
	if _used:
		return
	if body is Player:
		if bounce_force > 0.0:
			body.bounce(bounce_force)
		if damage > 0:
			body.take_damage(damage)
		if one_shot:
			_used = true
			visible = false
			set_deferred("monitoring", false)


func _on_body_exited(_body: Node) -> void:
	pass
