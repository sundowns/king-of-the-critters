extends Node2D

export var cheese_enabled = true
export var meat_enabled = true
export var timer_enabled = true
export var time_allowed = 1

var cheese_count: int = 0
var meat_count: int = 0
var rat_count: int = 0
var cat_count: int = 0
var crocodile_count: int = 0
var is_entity_counts_dirty = true
var tick_timer = 0
var player_won = false
var player_lost = false
var is_paused = false

const TICK_DURATION = 1 # 1 second

signal counts_changed(cheese_count, meat_count)
signal goals_set(cheese_enabled, meat_enabled, timer_enabled)
signal time_left_updated(time_left)
signal level_complete
signal level_failed

onready var entity_list = $Level/YSort
onready var level_timer: Timer = $Level/LevelTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(!timer_enabled or time_allowed > 0, "Level has a timer but no value provided :c")
	connect("level_complete", $GameUI/LevelCompleteUI, "show")
	connect("level_complete", $GameUI/PauseUI, "freeze")
	connect("level_failed", $GameUI/LevelFailedUI, "show")
	connect("level_failed", $GameUI/PauseUI, "freeze")
	emit_signal("goals_set", cheese_enabled, meat_enabled, timer_enabled)
	count_entities()
	if timer_enabled:
		initialise_timer()
	evaluate_end_conditions()

func initialise_timer():
	level_timer.start(time_allowed)
	emit_signal("time_left_updated", int(level_timer.time_left) -1)

func _process(delta):
	if is_entity_counts_dirty:
		count_entities()
		evaluate_end_conditions()
		is_entity_counts_dirty = false
		
	tick_timer += delta
	if tick_timer > TICK_DURATION:
		tick_timer -= TICK_DURATION
		check_for_level_win()
		emit_signal("time_left_updated", int(level_timer.time_left))
		
	if player_won:
		play_item_win_effect()
		yield(get_tree().create_timer(2.5), "timeout")
		emit_signal("level_complete")
		get_tree().paused = true
		return
	elif player_lost:
		emit_signal("level_failed")
		pause_all_entities()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().paused = true
		set_process(false)
		return
		

func pause_all_entities():
	var current_entities = $Level/YSort
	for node in current_entities.get_children():
		if node.has_node("Navigation"):
			node.force_stop()

func count_entities():
	cheese_count = 0
	meat_count = 0
	rat_count = 0
	cat_count = 0
	crocodile_count = 0
	for node in entity_list.get_children():
		if not node.has_node("Stats"):
			continue
		var stats = node.get_node("Stats")
		match stats.nav_alias:
			'Cheese':
				cheese_count += 1
			'Meat':
				meat_count += 1
			'Rat':
				rat_count += 1
			'Cat':
				cat_count += 1
			'Crocodile':
				crocodile_count += 1
	emit_signal("counts_changed", cheese_count, meat_count)

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
		player_lost = true

func check_for_level_win():
	if timer_enabled and level_timer.time_left <= 0:
		player_won = true
	
	if cheese_enabled and not meat_enabled:
		if rat_count <= 0:
			player_won = true

func on_entity_removal():
	is_entity_counts_dirty = true

func _on_restart_level():
	get_tree().paused = false
	get_tree().reload_current_scene()

func play_item_win_effect():
	var current_entities = $Level/YSort
	for node in current_entities.get_children():
		if node.has_node("ItemEffect"):
			node.play_hit_effect()

func freeze():
	pause_all_entities()
	get_tree().paused = true
	set_process(false)
	
