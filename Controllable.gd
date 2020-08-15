extends KinematicBody2D

onready var sprite = $CritterSprite
onready var crown_sprite = $CritterSprite/CritterCrown
onready var shader_material = sprite.material

export var Name: String

var outlined = false

func _ready():
	crown_sprite.visible = false

func _process(delta):
	if outlined:
		sprite.material = shader_material
	else:
		sprite.material = null

func set_is_targetted(is_targetted):
	outlined = is_targetted

func player_assumed_control():
	queue_free()
