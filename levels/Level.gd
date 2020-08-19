extends Node2D

export var cheese_enabled = true
export var meat_enabled = true
export var timer_enabled = true
export var time_allowed = 1

var cheese_count: int = 0
var meat_count: int = 0
var critter_count: int = 0
var is_entity_counts_dirty = true
var tick_timer = 0
var player_won = false
var player_lost = false

const TICK_DURATION = 1 # 1 second

signal counts_changed(cheese_count, meat_count, critter_count)
signal goals_set(cheese_enabled, meat_enabled, timer_enabled)
signal time_left_updated(time_left)

onready var entity_list = $Level/YSort
onready var level_timer: Timer = $Level/LevelTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(!timer_enabled or time_allowed > 0, "Level has a timer but no value provided :c")
	emit_signal("goals_set", cheese_enabled, meat_enabled, timer_enabled)
	count_entities()
	if timer_enabled:
		initialise_timer()
	evaluate_end_conditions()

func initialise_timer():
	level_timer.start(time_allowed)
	emit_signal("time_left_updated", int(level_timer.time_left) -1)

func _process(delta):
	tick_timer += delta
	if is_entity_counts_dirty:
		count_entities()
		evaluate_end_conditions()
		is_entity_counts_dirty = false
		
	if tick_timer > TICK_DURATION:
		tick_timer -= TICK_DURATION
		check_for_level_win()
		emit_signal("time_left_updated", int(level_timer.time_left))

func count_entities():
	cheese_count = 0
	meat_count = 0
	critter_count = 0
	for node in entity_list.get_children():
		if not node.has_node("Stats"):
			continue
		var stats = node.get_node("Stats")
		match stats.nav_alias:
			'Cheese':
				cheese_count += 1
			'Meat':
				meat_count += 1
			'Rat','Cat','Crocodile':
				critter_count += 1
	emit_signal("counts_changed", cheese_count, meat_count, critter_count)

func evaluate_end_conditions():
	check_for_level_loss()
	check_for_level_win()

func check_for_level_loss():
	var food_count = 0
	if cheese_enabled:
		food_count += cheese_count
	if meat_enabled:
		food_count += meat_count
	if food_count <= 0:
		print("Defeat - food sources depleted :c")
		
func check_for_level_win():
	if critter_count <= 0:
		print("Victory! - critters got owned")
	if timer_enabled and level_timer.time_left <= 0:
		print("Victory! - food sources protected")

func on_entity_removal():
	is_entity_counts_dirty = true
