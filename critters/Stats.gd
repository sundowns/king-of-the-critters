extends Node

export var max_health = 1
onready var health = max_health

func on_damage(damage):
	health -= damage
	if health <= 0:
		print("im ded") #TODO: signal things
