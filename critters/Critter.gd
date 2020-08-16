extends KinematicBody2D

onready var sprite = $CritterSprite
onready var crown_sprite = $CritterSprite/CritterCrown
onready var animation_player = $CritterSprite/AnimationPlayer
onready var shader_material = sprite.material
onready var navigation = $Navigation

export var critter_name: String
export var goal_node: String

enum CritterState {
	IDLE,
	WANDER,
	ATTACK
}

var state = CritterState.IDLE setget set_state
var outlined = false

func _ready():
	crown_sprite.visible = false
	if navigation:
		navigation.goal_node_name = goal_node

func _process(delta):
	if outlined:
		sprite.material = shader_material
	else:
		sprite.material = null
		
	match state:
		CritterState.WANDER:
			wander_state(delta)
		CritterState.IDLE:
			idle_state(delta)
		CritterState.ATTACK:
			attack_state(delta)

func idle_state(delta):
	animation_player.play("Idle")

func attack_state(delta):
	animation_player.play("Attack")

func wander_state(delta):
	animation_player.play("Walk")
	if navigation:
		navigation.set_process(true)
	# TODO: check if we're within eating range, if so change state to attack

func set_state(new_state):
	state = CritterState[new_state]

func set_is_targetted(is_targetted):
	outlined = is_targetted

func player_assumed_control():
	queue_free()
