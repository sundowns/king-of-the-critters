extends Control

onready var play_button: Button = $PlayButton

func _on_PlayButton_pressed():
	get_tree().change_scene("res://levels/test.tscn")
