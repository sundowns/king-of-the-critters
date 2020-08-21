extends KinematicBody2D

onready var stats = $Stats
onready var item_effect = $ItemEffect
onready var animation_player = $ItemEffect/AnimationPlayer

export var KNOCKBACK_FRICTION = 150

var knockback = Vector2.ZERO
signal item_removed
signal item_effect_finished

func _ready():
	connect("item_removed", get_tree().current_scene, "on_entity_removal")
	connect("item_effect_finished", get_tree().current_scene, "freeze_entities")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)

func on_hit(damage, knockback_vector):
	stats.take_damage(damage)
	knockback = knockback_vector
	
func play_hit_effect():
	stats.take_damage(-100)
	animation_player.play("Saved")
	item_effect.visible = true
	
func on_animation_end():
	item_effect.visible = false
	emit_signal("item_effect_finished")

func _on_Stats_no_health():
	emit_signal("item_removed")
	queue_free()
