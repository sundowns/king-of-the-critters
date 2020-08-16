extends Node2D

onready var nav_2d: Navigation2D = $Navigation2D
onready var c: KinematicBody2D = $YSort/Rat

func _unhandled_input(event) ->  void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return

	var new_path : = nav_2d.get_simple_path(rat.global_position, event.global_position)
#	rat.path
