extends Node

export var max_health = 1
export var nav_alias: String = ""
onready var health = max_health

signal no_health

func take_damage(damage):
	health -= damage
	print("Remaining health: %d" % health)
	if health <= 0:
		emit_signal("no_health")
