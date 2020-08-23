extends Node

func on_level_complete():
	$Victory.play()
	
func on_level_failed():
	$Defeat.play()
