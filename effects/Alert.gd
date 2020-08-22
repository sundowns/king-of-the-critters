extends AnimationPlayer

export var animation_name = "Alert"

func _ready():
	play(animation_name)

func _on_animation_finished():
	get_parent().queue_free()
