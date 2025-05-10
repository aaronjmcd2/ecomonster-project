# DragonWanderModule.gd
# Handles picking a new wander target for the Dragon

extends Node

func pick_wander_target(global_position: Vector2) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * 32
	return global_position + offset
