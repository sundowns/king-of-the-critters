extends Node

var levels: Array = [
	"test.tscn",
	"test.tscn"
]

var dialogue: Dictionary = {
	1: "I have been known to fug widdit indeedy"
}

var current_level_index = -1

func start_game():
	current_level_index = -1
	load_next_level()
	get_tree().change_scene("res://levels/%s" % levels[current_level_index])

func load_next_level():
	current_level_index += 1
	if current_level_index >= levels.size():
		all_levels_complete()
		return
	else:
		if dialogue.has(current_level_index):
			load_dialogue_scene()
		else: 
			get_tree().change_scene("res://levels/%s" % levels[current_level_index])
		

func load_dialogue_scene():
	var dialogue_scene: PackedScene = load("res://Dialogue.tscn")
	get_tree().change_scene_to(dialogue_scene)
	call_deferred('set_dialogue_scene_text', dialogue.get(current_level_index))

func set_dialogue_scene_text(text):
	get_tree().current_scene.dialogue = text

func all_levels_complete():
	get_tree().change_scene("res://UI/GameComplete.tscn")

func dialogue_finished():
	get_tree().change_scene("res://levels/%s" % levels[current_level_index])
