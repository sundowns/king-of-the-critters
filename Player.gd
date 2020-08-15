extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500

enum PlayerState {
	CROWN,
	CONTROLLING
}

const critter_scene_path_format = "res://{str}.tscn"

var velocity = Vector2.ZERO
var state = PlayerState.CROWN
var control_target: KinematicBody2D = null
var current_critter_type: String = ""

onready var animation_player = $AnimationPlayer
onready var crown_sprite = $Crown
onready var collision_shape = $CollisionShape2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	match state:
		PlayerState.CROWN:
			move_crown_state(delta, input_vector)
		PlayerState.CONTROLLING:
			move_controlled_state(delta, input_vector)

func move_crown_state(delta, input_vector):
	crown_sprite.visible = true
	animation_player.play("Move")
	player_movement(delta, input_vector)
	move()
	check_target()

func move_controlled_state(delta, input_vector):
	get_node("CritterSprite").visible = true
	player_movement(delta, input_vector)
	move()
	if Input.is_action_just_pressed("ui_accept"):
		release_target()
	
func player_movement(delta, input_vector):
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) 

func move():
	velocity = move_and_slide(velocity)

func check_target():
	if control_target:
		control_target.set_is_targetted(true)
		if Input.is_action_just_pressed("ui_accept"):
			assume_control_of_target()

func assume_control_of_target():
	crown_sprite.visible = false
	var critter_sprite = control_target.get_node("CritterSprite").duplicate()
	critter_sprite.material = null
	critter_sprite.visible = true
	critter_sprite.get_node("CritterCrown").visible = true
	add_child(critter_sprite)
	
	collision_shape.disabled = false
	current_critter_type = control_target.name
	control_target.player_assumed_control()
	state = PlayerState.CONTROLLING

func release_target():
	crown_sprite.visible = false
	collision_shape.disabled = true
	get_node("CritterSprite").queue_free()
	control_target = null
	
	# Probably a much better way to do this but idk
	var new_critter = load(critter_scene_path_format.format({"str": current_critter_type})).instance()
	new_critter.global_position = global_position
	get_parent().add_child(new_critter)
	state = PlayerState.CROWN

func _on_CritterDetectionZone_body_entered(body):
	control_target = body

func _on_CritterDetectionZone_body_exited(body):
	control_target.set_is_targetted(false)
	control_target = null
