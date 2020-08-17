extends Area2D

#const hit_effect = preload("res://Effects/HitEffect.tscn")

export(bool) var show_hit = true

func _on_Hurtbox_area_entered(area):
	if get_parent().is_a_parent_of(area):
		return
	# TODO: show a hit effect
#	if show_hit:
#		var effect = hit_effect.instance()
#		get_tree().current_scene.add_child(effect)
#		effect.global_position = global_position - Vector2(0,0)
