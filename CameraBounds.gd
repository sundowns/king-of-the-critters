extends Camera2D

onready var top_left: Position2D = $Bounds/TopLeft
onready var bottom_right: Position2D = $Bounds/BottomRight

func _ready():
	limit_top = int(top_left.global_position.y)
	limit_left = int(top_left.global_position.x)
	limit_bottom = int(bottom_right.global_position.y)
	limit_right = int(bottom_right.global_position.x)
