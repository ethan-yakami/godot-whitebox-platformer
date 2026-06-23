extends CharacterBody2D
class_name Enemy

signal defeated(enemy: Enemy)

@export var speed := 96.0
@export var health := 4
@export var patrol_distance := 180.0
@export var attack_damage := 1
@export var trigger_range := 220.0

var player: Player
var origin := Vector2.ZERO
var direction := 1
var gravity := 1600.0


func _ready() -> void:
	_ensure_whitebox()
	origin = global_position


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	var target_dir := direction
	if player != null and global_position.distance_to(player.global_position) < trigger_range:
		target_dir = signf(player.global_position.x - global_position.x)
		if target_dir == 0.0:
			target_dir = direction
	elif absf(global_position.x - origin.x) > patrol_distance:
		direction *= -1
		target_dir = direction

	direction = int(target_dir)
	velocity.x = direction * speed
	move_and_slide()


func hit(amount: int) -> void:
	health -= amount
	if health <= 0:
		defeated.emit(self)
		queue_free()


func _on_touch(body: Node) -> void:
	if body is Player:
		body.take_damage(attack_damage)


func _ensure_whitebox() -> void:
	if get_node_or_null("CollisionShape2D") == null:
		var collision := CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(48, 56)
		collision.shape = shape
		collision.position = Vector2(0, -28)
		add_child(collision)

	if get_node_or_null("Visual") == null:
		var visual := ColorRect.new()
		visual.name = "Visual"
		visual.size = Vector2(48, 56)
		visual.position = Vector2(-24, -56)
		visual.color = Color(0.05, 0.05, 0.07) if health <= 4 else Color(0.28, 0.05, 0.05)
		add_child(visual)

	if get_node_or_null("TouchDamage") == null:
		var touch := Area2D.new()
		touch.name = "TouchDamage"
		var collision := CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(60, 60)
		collision.shape = shape
		collision.position = Vector2(0, -30)
		touch.add_child(collision)
		touch.body_entered.connect(_on_touch)
		add_child(touch)
