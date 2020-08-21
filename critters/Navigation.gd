extends Area2D

onready var parent: Node2D = get_parent()
onready var nav_map: Navigation2D = get_tree().current_scene.get_node("Level/NavigationMap")
onready var hitbox: CollisionShape2D = get_parent().get_node("CollisionShape2D")

export var speed: float = 1
export var hitbox_leniancy = 3

var current_target: Node = null
var goal_node_names: Array setget set_goal_node # Provided by parent
var path := PoolVector2Array() setget set_path

func _ready():
	set_process(false)

func _process(delta):
	if current_target:
		set_path_to_target()
	move_along_path(delta)
	
func set_goal_node(new_goal_name):
	goal_node_names = new_goal_name

func move_along_path(delta: float):
	var distance = speed * delta # used for estimating distance to point
	var start_point: Vector2 = parent.global_position
	for _i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		var direction_to_next = start_point.direction_to(path[0])
		if distance + hitbox_leniancy <= distance_to_next and distance >= 0.0:
			# move_and_slide uses delta already, just pass speed
			parent.move_and_slide(direction_to_next * speed)
			break
		elif path.size() == 1 && distance + hitbox_leniancy > distance_to_next:
			# We made it to the end
			parent.global_position = path[0]
			set_process(false)
		# If we didn't run out of distance this frame, move to the next point
		distance -= (distance_to_next - hitbox_leniancy)
		start_point = path[0]
		path.remove(0)

func set_path(value: PoolVector2Array):
	path = value
	if value.size() == 0:
		return

func set_path_to_target():
	set_path(nav_map.get_simple_path(parent.global_position, current_target.global_position, false))

func _on_Navigation_body_entered(body: Node):
	if not is_goal_node(body):
		return
	if not current_target:
		current_target = body
		parent.state = 'CHASE'
	if current_target and current_target.get_instance_id() != body.get_instance_id():
		# check which is closer and use that one
		if body.global_position.distance_to(parent.global_position) < current_target.global_position.distance_to(parent.global_position):
			current_target = body
			parent.state = 'CHASE'

func _on_Navigation_body_exited(body: Node):
	if not current_target:
		return
	if not is_goal_node(body):
		return
	if body.get_instance_id() == current_target.get_instance_id():
		path = PoolVector2Array()
		var previous_target = current_target
		current_target = null
		for other_body in get_overlapping_bodies():
			if is_goal_node(other_body) and other_body.get_instance_id() != previous_target.get_instance_id():
				current_target = other_body
				parent.state = 'CHASE'
				return
		parent.state = 'IDLE'

func is_goal_node(body):
	if not body.has_node('Stats'):
		return false
	var stats = body.get_node('Stats')
	return goal_node_names.has(stats.nav_alias)

func force_stop():
	set_process(false)
