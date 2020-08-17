extends StaticBody2D

onready var stats = $Stats

func on_hit(damage):
	stats.take_damage(damage)

func _on_Stats_no_health():
	queue_free()
