extends KinematicBody2D

onready var sprite = $CritterSprite
onready var crown_sprite = $CritterSprite/CritterCrown
onready var animation_player = $CritterSprite/AnimationPlayer
onready var shader_material = sprite.material
onready var navigation = $Navigation
onready var stats = $Stats
onready var critter_attack = $CritterAttack

const alert_scene = preload("res://critters/Alert.tscn")
const question_mark_scene = preload("res://critters/QuestionMark.tscn")

export var KNOCKBACK_FRICTION = 150
export var KNOCKBACK_FORCE: int = 80
export var critter_name: String
export(Array) var goal_nodes: Array

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

func idle_state(delta):
	animation_player.play("Idle")

func attack_state(delta):
	if attack_target:
		attack_current_target()

func chase_state(delta):
	attack_target = null
	animation_player.play("Walk")
	if navigation:
		navigation.set_process(true)
	# TODO: sort out continuing to attack an adjacent target somehow :/
#	for attackable in critter_attack.get_overlapping_areas():
#		hunt_new_target(attackable.get_parent())
#		break

func set_state(new_state):
	state = CritterState[new_state]
	if state == CritterState.CHASE:
		create_alert()
	elif state == CritterState.IDLE:
		create_question_mark() # TODO: probably not sufficient once we have eating/destroying target

func create_question_mark():
	clear_alerts()
	var question_mark = question_mark_scene.instance()
	question_mark.global_position = get_parent().global_position
	add_child(question_mark, true)

func create_alert():
	clear_alerts()
	var alert = alert_scene.instance()
	alert.global_position = get_parent().global_position
	add_child(alert, true)

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

func _on_CritterAttack_area_entered(area):
	if navigation.current_target.get_instance_id() == area.get_parent().get_instance_id():
		hunt_new_target(area.get_parent())

func _on_CritterSprite_attack_animation_ended():
	# TODO: maaaaybe play our attack here instead so we can pick based on attacker
	var knockback_vector = global_position.direction_to(attack_target.global_position)
	attack_target.on_hit(critter_attack.damage, knockback_vector * KNOCKBACK_FORCE)
	state = CritterState.CHASE
	
func _on_Stats_no_health():
	queue_free()
