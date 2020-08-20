extends Control

onready var button = $Button

signal next_level

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("next_level", Global, "load_next_level")

func show():
	if Global.current_level_index == Global.levels.size() - 1:
		emit_signal("next_level")
	else:
		visible = true

func _on_Button_pressed():
	emit_signal("next_level")
