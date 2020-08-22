extends KinematicBody2D

export var KNOCKBACK_FRICTION = 150
export var KNOCKBACK_FORCE: int = 80
export(Array) var goal_nodes: Array

const ATTACK_FROM_CHASE_DELAY = 0.75
const alert_scene = preload("res://effects/Alert.tscn")
const question_mark_scene = preload("res://effects/QuestionMark.tscn")

onready var sprite = $CritterSprite
onready var crown_sprite = $CritterSprite/CritterCrown
onready var animation_player = $CritterSprite/AnimationPlayer
onready var shader_material = sprite.material
onready var navigation = $Navigation
onready var stats = $Stats
onready var critter_attack = $CritterAttack
onready var attack_from_chase_timer = ATTACK_FROM_CHASE_DELAY
onready var hit_effect_scene = preload("res://effects/HitEffect.tscn") #TODO: other hit effects

signal critter_removed

enum CritterState {
	IDLE,
	CHASE,
	ATTACK
}

var state = CritterState.IDLE setget set_state
var outlined = false
var attack_target: Node2D = null
var knockback = Vector2.ZERO

func _ready():
	connect("critter_removed", get_tree().current_scene, "on_entity_removal")
	crown_sprite.visible = false
	if navigation:
		navigation.goal_node_names = goal_nodes

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)

func _process(delta):
	if outlined:
		sprite.material = shader_material
	else:
		sprite.material = null
	
	match state:
		CritterState.CHASE:
			chase_state(delta)
			return
		CritterState.IDLE:
			idle_state(delta)
			return
		CritterState.ATTACK:
			attack_state(delta)
			return

func idle_state(_delta):
	animation_player.play("Idle")

func attack_state(_delta):
	if attack_target:
		attack_current_target()

func chase_state(delta):
	animation_player.play("Walk")
	if navigation:
		navigation.set_process(true)
		
	attack_from_chase_timer -= delta
	if attack_from_chase_timer <= 0:
		for attackable in critter_attack.get_overlapping_areas():
			if attack_target:
				if attack_target.get_instance_id() == attackable.get_parent().get_instance_id():
					hunt_new_target(attackable.get_parent())
			else:
				hunt_new_target(attackable.get_parent())
			break

func set_state(new_state):
	# This is only used when some external code sets this
	state = CritterState[new_state]
	if state == CritterState.CHASE:
		create_alert()
	elif state == CritterState.IDLE:
		create_question_mark() 

func create_question_mark():
	clear_alerts()
	var question_mark = question_mark_scene.instance()
	question_mark.global_position = get_parent().global_position
	call_deferred('add_child', question_mark, true) 

func create_alert():
	clear_alerts()
	var alert = alert_scene.instance()
	alert.global_position = get_parent().global_position
	add_child(alert, true)
	
func create_hit_effect(target: Node2D):
	if not target:
		return
	var hit_effect = hit_effect_scene.instance()
	add_child(hit_effect)
	hit_effect.global_position = hit_effect.global_position.move_toward(target.global_position, hit_effect.global_position.distance_to(target.global_position) * 0.75)

func clear_alerts():
	var node = find_node("Alert*", true, false)
	if node:
		node.queue_free()

func set_is_targetted(is_targetted):
	outlined = is_targetted

func player_assumed_control():
	queue_free()

func attack_current_target():
	animation_player.play("Attack")

func on_hit(damage, knockback_vector):
	stats.take_damage(damage)
	knockback = knockback_vector

func hunt_new_target(target):
	attack_target = target
	state = CritterState.ATTACK

func reset_chase_attack_timer():
	attack_from_chase_timer = ATTACK_FROM_CHASE_DELAY

func _on_CritterSprite_attack_animation_ended():
	if not attack_target:
		return
	create_hit_effect(attack_target)
	var knockback_vector = global_position.direction_to(attack_target.global_position)
	attack_target.on_hit(critter_attack.damage, knockback_vector * KNOCKBACK_FORCE)
	state = CritterState.CHASE
	reset_chase_attack_timer()
	# TODO: set a timer/delay before
	
func _on_Stats_no_health():
	emit_signal("critter_removed")
	queue_free()

func force_stop():
	$Navigation.stop()
	set_process(false)
