extends Control

onready var button = $Button

signal restart_level

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):	
	if Input.is_action_just_pressed("ui_cancel"):
		var tree = get_tree()
		if tree.paused:
			unpause(tree)
		else:
			pause(tree)

func pause(tree):
	tree.paused = true
	button.visible = true

func unpause(tree):
	tree.paused = false
	button.visible = false

func _on_Button_pressed():
	emit_signal("restart_level")
