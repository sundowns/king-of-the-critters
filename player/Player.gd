extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500

enum PlayerState {
	CROWN,
	CONTROLLING
}

const critter_scene_path_format = "res://critters/{str}.tscn"
const sprite_walk_rotation = 4

var velocity = Vector2.ZERO
var state = PlayerState.CROWN
var control_target: KinematicBody2D = null
var current_critter_type: String = ""

onready var animation_player = $AnimationPlayer
onready var crown_sprite = $Crown
onready var collision_shape = $CollisionShape2D

onready var critter_detection_zone = $CritterDetectionZone
onready var critter_detection_zone_collision = $CritterDetectionZone/CollisionShape2D

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
	detect_critters()

func move_controlled_state(delta, input_vector):
	var critter_sprite = get_node("CritterSprite")
	critter_sprite.visible = true
	player_movement(delta, input_vector)
	move()
	rotate_critter_sprite(critter_sprite, input_vector)
	if Input.is_action_just_pressed("ui_accept"):
		release_target()

func rotate_critter_sprite(critter_sprite, input_vector):
	if input_vector.x > 0:
		critter_sprite.rotation_degrees = sprite_walk_rotation
	elif input_vector.x < 0:
		critter_sprite.rotation_degrees = -sprite_walk_rotation
	else:
		critter_sprite.rotation_degrees = 0

func player_movement(delta, input_vector):
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) 

func move():
	velocity = move_and_slide(velocity)

func detect_critters():
	var closest_body = null
	for body in critter_detection_zone.get_overlapping_bodies():
		if not closest_body:
			closest_body = body
		elif body.global_position.distance_to(critter_detection_zone.global_position) < closest_body.global_position.distance_to(critter_detection_zone.global_position):
			# compare their distance and keep the closer one
			closest_body = body
	if closest_body:
		update_control_target(closest_body)
	elif control_target:
		reset_control_target()
	if control_target:
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
	global_position = control_target.global_position
	control_target.player_assumed_control()
	control_target = null
	critter_detection_zone_collision.disabled = true
	state = PlayerState.CONTROLLING

func release_target():
	crown_sprite.visible = false
	collision_shape.disabled = true
	get_node("CritterSprite").queue_free()
	critter_detection_zone_collision.disabled = false
	
	# Probably a much better way to do this but idk
	var new_critter = load(critter_scene_path_format.format({"str": current_critter_type})).instance()
	new_critter.global_position = global_position
	get_parent().add_child(new_critter)
	state = PlayerState.CROWN

func update_control_target(new_target):
	if control_target:
		reset_control_target()
	control_target = new_target
	new_target.set_is_targetted(true)

func reset_control_target():
	control_target.set_is_targetted(false)
	control_target = null
