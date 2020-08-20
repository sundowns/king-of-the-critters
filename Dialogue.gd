extends Control

# maybe just a string tbh
export var dialogue: String = "" setget set_dialogue

onready var animation_player = $Crown/AnimationPlayer
onready var dialogue_box = $DialogueBox/RichTextLabel
onready var tween = $DialogueBox/Tween
onready var timer = $Timer
onready var prompt = $Prompt

signal dialogue_scene_finished

func _ready():
	connect("dialogue_scene_finished", Global, "dialogue_finished")
	prompt.visible = false
	get_tree().paused = false
	set_process(true)
	animation_player.play("Dialogue")
	prepare_text()
	
func _process(delta):
	if dialogue_box.percent_visible == 1:
		prompt.visible = true
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("dialogue_scene_finished")

func set_dialogue(new_value):
	dialogue = new_value
	prepare_text()

func prepare_text():
	dialogue_box.bbcode_text = dialogue.to_lower()
	dialogue_box.percent_visible = 0
	tween.interpolate_property(dialogue_box, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
