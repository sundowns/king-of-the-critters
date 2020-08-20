extends Control

onready var button = $Button

signal restart_level

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("restart_level", get_tree().current_scene, "_on_restart_level")

func show():
	visible = true

func _on_Button_pressed():
	emit_signal("restart_level")
