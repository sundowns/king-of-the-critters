extends Node



export var max_health = 1
export var nav_alias: String = ""
onready var health = max_health

signal no_health

func set_health(new_health):
	health = min(new_health, max_health)

func take_damage(damage):
	set_health(health - damage)
	if health <= 0:
		emit_signal("no_health")
