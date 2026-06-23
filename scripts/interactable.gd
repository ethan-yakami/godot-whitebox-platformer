extends Area2D
class_name Interactable

signal interacted(kind: String, node: Node)

@export var kind := "berry"
@export var message := ""

var player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("attack_interact"):
		interacted.emit(kind, self)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_inside = true
		modulate = Color(1.4, 1.4, 1.4)
		if kind == "checkpoint":
			GameState.set_checkpoint(global_position)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_inside = false
		modulate = Color.WHITE
