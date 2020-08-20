extends Control

onready var play_button: Button = $PlayButton

func _on_PlayButton_pressed():
	Global.start_game()
