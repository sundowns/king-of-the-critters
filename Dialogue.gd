extends Control

onready var animation_player = $Crown/AnimationPlayer
onready var dialogue_box = $DialogueBox/RichTextLabel
onready var tween = $DialogueBox/Tween
onready var timer = $Timer
onready var finish_prompt = $FinishPrompt
onready var next_prompt = $NextPrompt

export var dialogue: Array = [] setget set_dialogue
var dialogue_index = 0

signal dialogue_scene_finished

func _ready():
	connect("dialogue_scene_finished", Global, "dialogue_finished")
	finish_prompt.visible = false
	next_prompt.visible = false
	get_tree().paused = false
	set_process(true)
	animation_player.play("Dialogue")
	prepare_text()
	
func _process(delta):
	if dialogue_box.percent_visible == 1:
		if dialogue_index + 1 == dialogue.size():
			# we've finished our dialogue
			finish_prompt.visible = true
			if Input.is_action_just_pressed("ui_accept"):
				emit_signal("dialogue_scene_finished")
		else:
			# show the next line
			next_prompt.visible = true
			if Input.is_action_just_pressed("ui_accept"):
				dialogue_index += 1
				prepare_text()

func set_dialogue(new_value):
	dialogue = new_value
	dialogue_index = 0
	prepare_text()

func prepare_text():
	if dialogue.size() == 0:
		return
	next_prompt.visible = false
	var record = dialogue[dialogue_index]
	dialogue_box.bbcode_text = record[0].to_lower()
	var display_text_duration = 1.5
	if record.size() > 1:
		display_text_duration = record[1]
	dialogue_box.percent_visible = 0
	tween.interpolate_property(dialogue_box, "percent_visible", 0, 1, display_text_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
