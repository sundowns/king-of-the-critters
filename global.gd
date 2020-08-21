extends Node

var levels: Array = [
	"tutorial1.tscn",
	"tutorial2.tscn",
	"test.tscn"
]

var dialogue: Dictionary = {
	0: [["For so long have I watched over the critters of the forest... so so long", 4.5], ["All they do is eat..... All day long they feast on cheese and steak", 4], ["Is this right? Does the food hurt? Who watches over cheese?", 4], ["Was I wrong all this time? Food needs protecting...not critters", 4], ["Thats it! I will use the sacred powers of the SPACE BAR to protect all food.", 4], ["I..... I MUST PROTECT CHEESE..................", 2], [".....................with the SPACE BAR!", 2]],
	1: [["It seems I was right... The cheese was rescued by a power even mightier than I!", 4], ["I see the signs and accept this mission. I will protect the foods of the forest!",3.5], ["No critter can stop me!", 1.25], ["Well..... as long as there is only one!",2]]
}

var current_level_index = -1

func start_game():
	current_level_index = 0
	load_dialogue_scene()

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
