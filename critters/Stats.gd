extends Node



export var max_health = 1
export var nav_alias: String = ""
onready var health = max_health

signal no_health

func set_health(new_health):
	health = new_health

func take_damage(damage):
	health -= damage
	if health <= 0:
		emit_signal("no_health")
