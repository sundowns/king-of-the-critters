extends Particles2D


func on_play_animation_end():
	$AnimationPlayer.play("Finished")
	get_parent().on_animation_end()
