extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500

enum PlayerState {
	CROWN,
	CONTROLLING
}

const critter_movespeed_modifiers = {
	"Cat": 0.85,
	"Rat": 1.0,
	"Crocodile": 0.4
}
const critter_scene_path_format = "res://critters/{str}.tscn"
const sprite_walk_rotation = 4
# insane hack.... tile atlas seems to be kind of terrible
const CLOSED_DOOR_CELL_ID = 7
const OPEN_DOOR_CELL_ID = 8

var velocity = Vector2.ZERO
var state = PlayerState.CROWN
var control_target: KinematicBody2D = null
var current_critter_type: String = ""
var current_critter_health: int = 1
var is_highlighting_door: bool = false

onready var animation_player = $Crown/AnimationPlayer
onready var crown_sprite = $Crown
onready var collision_shape = $CollisionShape2D
onready var critter_detection_zone = $CritterDetectionZone
onready var critter_detection_zone_collision = $CritterDetectionZone/CollisionShape2D
onready var particle_emitter: Particles2D = $AttachCritterParticles
onready var camera_transform: RemoteTransform2D = $CameraTransform2D
onready var tile_map: TileMap = get_tree().current_scene.find_node("TileAtlasWithBackground")

onready var door_open_sound: AudioStreamPlayer2D = $DoorOpenSound
onready var door_closed_sound: AudioStreamPlayer2D = $DoorCloseSound
onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

signal entity_released

func _ready():
	# attach our remote transform to the scenes camera if there is one
	animation_player.play("Move")
	var camera = get_tree().current_scene.find_node("Camera2D")
	if camera:
		camera_transform.remote_path = camera.get_path()
	connect("entity_released", get_tree().current_scene, "on_entity_release")

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
			

func _process(delta):
	# yeeeeeeeeeeeeeeeeee haw
	if is_highlighting_door:
		$Crown/HighlightedShadow.visible = true
		$Crown/Shadow.visible = false
	else:
		$Crown/HighlightedShadow.visible = false
		$Crown/Shadow.visible = true

func move_crown_state(delta, input_vector):
	crown_sprite.visible = true
	animation_player.play("Move")
	player_movement(delta, input_vector)
	move()
	if control_target == null: # no critter being targetted
		detect_doors()
	detect_critters()

func move_controlled_state(delta, input_vector):
	var critter_sprite = get_node("CritterSprite")
	critter_sprite.visible = true
	player_movement(delta, input_vector, critter_movespeed_modifiers[current_critter_type])
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

func player_movement(delta, input_vector, modifier = 1.0):
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED * modifier, ACCELERATION * delta)
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

func detect_doors():
	if tile_map:
		var player_tilemap_pos = tile_map.world_to_map(global_position)
		var cell_id = tile_map.get_cellv(player_tilemap_pos)
		# if it is a door, check for action
		if cell_id == OPEN_DOOR_CELL_ID or cell_id == CLOSED_DOOR_CELL_ID:
			is_highlighting_door = true
			# if input pressed, swap it to the other index (closed vs open)
			if Input.is_action_just_pressed("ui_accept"):
				if cell_id == OPEN_DOOR_CELL_ID:
					door_closed_sound.play()
					tile_map.set_cellv(player_tilemap_pos, CLOSED_DOOR_CELL_ID)
				elif cell_id == CLOSED_DOOR_CELL_ID:
					door_open_sound.play()
					tile_map.set_cellv(player_tilemap_pos, OPEN_DOOR_CELL_ID)
		else: 
			is_highlighting_door = false


func assume_control_of_target():
	particle_emitter.restart()
	pickup_sound.play()
	crown_sprite.visible = false
	var critter_sprite = control_target.get_node("CritterSprite").duplicate()
	critter_sprite.material = null
	critter_sprite.visible = true
	critter_sprite.get_node("CritterCrown").visible = true
	add_child(critter_sprite)
	
	collision_shape.disabled = false
	current_critter_type = control_target.stats.nav_alias
	current_critter_health = control_target.stats.health
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
	
	# Spawn our critter back
	var new_critter = load(critter_scene_path_format.format({"str": current_critter_type})).instance()
	new_critter.global_position = global_position
	
	get_parent().add_child(new_critter)
	# seems like this has to be done after adding as a child or stat values dont get set (cause its onready probably?)
	new_critter.get_node("Stats").set_health(current_critter_health)
	current_critter_type = ""
	state = PlayerState.CROWN

func update_control_target(new_target):
	if control_target:
		reset_control_target()
	control_target = new_target
	new_target.set_is_targetted(true)

func reset_control_target():
	control_target.set_is_targetted(false)
	control_target = null
	
