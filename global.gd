extends Node

var levels: Array = [
	"test.tscn",
	"test.tscn"
]
var current_level_index = 0

func start_game():
	current_level_index = 0
	get_tree().change_scene("res://levels/%s" % levels[current_level_index])

func load_next_level():
	current_level_index += 1
	if current_level_index >= levels.size():
		all_levels_complete()
		return
	else:
		get_tree().change_scene("res://levels/%s" % levels[current_level_index])
		get_tree().paused = false

func all_levels_complete():
	get_tree().change_scene("res://UI/GameComplete.tscn")
