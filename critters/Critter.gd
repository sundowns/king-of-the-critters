extends KinematicBody2D

onready var sprite = $CritterSprite
onready var crown_sprite = $CritterSprite/CritterCrown
onready var animation_player = $CritterSprite/AnimationPlayer
onready var shader_material = sprite.material
onready var navigation = $Navigation

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
	animation_player.play("Attack")

func chase_state(delta):
	animation_player.play("Walk")
	
	if navigation:
		navigation.set_process(true)
	# TODO: check if we're within eating range, if so change state to attack

func set_state(new_state):
	state = CritterState[new_state]
	if state == CritterState.CHASE:
		create_alert()
#	elif state == CritterState.IDLE:
#		create_question_mark() # TODO: probably not sufficient once we have eating/destroying target

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
