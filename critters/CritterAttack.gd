extends Area2D

onready var timer = $Timer

export var damage = 1

signal attack

func start_cooldown():
	timer.start()

func _on_Timer_timeout():
	timer.stop()
	emit_signal("attack")
