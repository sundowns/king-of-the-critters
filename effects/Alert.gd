extends AnimationPlayer

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	play()

func _on_animation_finished():
	pass
#	get_parent().queue_free()
