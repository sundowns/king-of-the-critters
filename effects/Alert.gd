extends AnimationPlayer

export var animation_name = "Alert"

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	play(animation_name)

func _on_animation_finished():
	get_parent().queue_free()
