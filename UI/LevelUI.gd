extends Control

var cheese_count = 0
var meat_count = 0
var critter_count = 0

func set_counts(new_cheese_count, new_meat_count, new_critter_count):
	cheese_count = max(new_cheese_count, 0)
	meat_count = max(new_meat_count, 0)
	critter_count = max(new_critter_count, 0)

func _ready():
	get_tree().current_scene.connect("counts_changed", self, "set_counts")


# TODO: this is working, just need to draw it on our UI weee
