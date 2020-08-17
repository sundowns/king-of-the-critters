extends Sprite

signal attack_animation_ended

func on_attack_end():
	emit_signal("attack_animation_ended")
