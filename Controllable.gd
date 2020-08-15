extends KinematicBody2D

onready var sprite = $Sprite
onready var shader_material = sprite.material

export var outlined = false

func _process(delta):
	if outlined:
		sprite.material = shader_material
	else:
		sprite.material = null

func set_is_targetted(is_targetted):
	outlined = is_targetted
