extends Control

onready var play_button: Button = $PlayButton

func _ready():
	$Crown/AnimationPlayer.play("Dialogue")

func _on_PlayButton_pressed():
	Global.start_game()
