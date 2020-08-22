extends Control

onready var button = $Button

signal restart_level

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("restart_level", get_tree().current_scene, "_on_restart_level")
	set_process(false)

func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	set_process(true)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("restart_level")

func _on_Button_pressed():
	emit_signal("restart_level")
