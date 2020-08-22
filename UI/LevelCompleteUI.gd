extends Control

onready var button = $Button

signal next_level

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("next_level", Global, "load_next_level")
	set_process(false)

func show():
	if Global.current_level_index == Global.levels.size() - 1:
		emit_signal("next_level")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		visible = true
		set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("next_level")

func _on_Button_pressed():
	emit_signal("next_level")
