extends Enemy
class_name Ghost


func _ready() -> void:
	super._ready()
	speed = 128.0
	health = 2
	attack_damage = 1
	modulate = Color(0.55, 0.75, 1.0, 0.7)
