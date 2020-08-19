extends Control

onready var cheese_count_label: Label = $Container/CheeseControl/Cheese
onready var meat_count_label: Label = $Container/MeatControl/Meat
onready var timer_count_label: Label = $Container/TimeControl/Time

onready var cheese_container: Container = $Container/CheeseControl
onready var meat_container: Container = $Container/MeatControl
onready var timer_container: Container = $Container/TimeControl

var cheese_count = 0
var meat_count = 0
var critter_count = 0
var time_count = 0

func _ready():
	get_tree().current_scene.connect("counts_changed", self, "set_counts")
	get_tree().current_scene.connect("goals_set", self, "set_flags")
	get_tree().current_scene.connect("time_left_updated", self, "set_time")

func set_flags(cheese_enabled, meat_enabled, time_enabled):
	cheese_container.visible = cheese_enabled
	meat_container.visible = meat_enabled
	timer_container.visible = time_enabled

func set_counts(new_cheese_count, new_meat_count, new_critter_count):
	cheese_count = max(new_cheese_count, 0)
	meat_count = max(new_meat_count, 0)
	critter_count = max(new_critter_count, 0)
	update_labels()

func set_time(time):
	time_count = time
	update_labels()

func update_labels():
	cheese_count_label.text = str(cheese_count)
	meat_count_label.text = str(meat_count)
	timer_count_label.text = str(time_count)
