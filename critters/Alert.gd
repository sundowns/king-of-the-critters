extends AnimationPlayer

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	play("Alert")

func _on_animation_finished():
	get_parent().queue_free()
