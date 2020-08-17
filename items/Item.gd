extends KinematicBody2D

onready var stats = $Stats

export var KNOCKBACK_FRICTION = 150

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)

func on_hit(damage, knockback_vector):
	stats.take_damage(damage)
	knockback = knockback_vector

func _on_Stats_no_health():
	queue_free()
