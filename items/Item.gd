extends KinematicBody2D

onready var stats = $Stats

export var KNOCKBACK_FRICTION = 150

var knockback = Vector2.ZERO
signal item_removed

func _ready():
	connect("item_removed", get_tree().current_scene, "on_entity_removal")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)

func on_hit(damage, knockback_vector):
	stats.take_damage(damage)
	knockback = knockback_vector

func _on_Stats_no_health():
	emit_signal("item_removed")
	queue_free()
