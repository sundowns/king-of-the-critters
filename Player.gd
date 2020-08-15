extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500

enum PlayerState {
	MOVE
}

var velocity = Vector2.ZERO
var state = PlayerState.MOVE
var control_target = null

onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	match state:
		PlayerState.MOVE:
			move_state(delta, input_vector)
			
func move_state(delta, input_vector):
	animation_player.play("Move")
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) 
	move()
	check_target()

func move():
	velocity = move_and_slide(velocity)

func check_target():
	if control_target:
		control_target.set_is_targetted(true)

func _on_CritterDetectionZone_body_entered(body):
	control_target = body

func _on_CritterDetectionZone_body_exited(body):
	control_target.set_is_targetted(false)
	control_target = null
