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

func _ready():
	crown_sprite.visible = false
	if navigation:
		navigation.goal_node_names = goal_nodes

func _process(delta):
	if outlined:
		sprite.material = shader_material
	else:
		sprite.material = null
	
	match state:
		CritterState.CHASE:
			chase_state(delta)
		CritterState.IDLE:
			idle_state(delta)
		CritterState.ATTACK:
			attack_state(delta)

func idle_state(delta):
	animation_player.play("Idle")

func attack_state(delta):
	if attack_target:
		attack_current_target()
	else:
		print('nuffin 2 attack :c')

func chase_state(delta):
	attack_target = null
	animation_player.play("Walk")
	if navigation:
		navigation.set_process(true)
	for attackable in critter_attack.get_overlapping_areas():
		hunt_new_target(attackable.get_parent())
		break

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

func on_hit(damage):
	# TODO: play hit effect here! (maybe not, see comment in _on_CritterSprite_attack_animation_ended)
	stats.take_damage(damage)

func hunt_new_target(target):
	attack_target = target
	state = CritterState.ATTACK

func _on_CritterAttack_area_entered(area):
	if not attack_target:
		hunt_new_target(area.get_parent())

func _on_CritterAttack_attack():
	if state == CritterState.ATTACK:
		attack_current_target()

func _on_CritterSprite_attack_animation_ended():
	# TODO: maaaaybe play our attack here instead so we can pick based on attacker
	attack_target.on_hit(critter_attack.damage)
	critter_attack.start_cooldown()

func _on_Stats_no_health():
	queue_free()
