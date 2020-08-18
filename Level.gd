extends Node2D

var cheese_count: int = 0
var meat_count: int = 0
var critter_count: int = 0
var is_dirty = true

onready var entity_list = $YSort

# Called when the node enters the scene tree for the first time.
func _ready():
	count_entities()
	evaluate_counts()
	
func _process(delta):
	if is_dirty:
		count_entities()
		evaluate_counts()
		is_dirty = false

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

func evaluate_counts():
	# TODO: trigger the win/loss conditions here
	print("---------")
	print("critters: %d" % critter_count)
	print("cheese: %d" % cheese_count)
	print("meat: %d" % meat_count)
	check_for_level_loss()
	check_for_level_win()

func check_for_level_loss():
	if cheese_count + meat_count <= 0:
		print("Game over, u lose :c")
		
func check_for_level_win():
	# TODO: check a timer here as well
	if critter_count <= 0:
		print("Critters all gone, u win this level m8")

func on_entity_removal():
	is_dirty = true
