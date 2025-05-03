# DragonMovementModule.gd
# Handles movement toward a given target and triggers consume behavior when close

extends Node

func move_toward_target(
	delta: float,
	self_node: CharacterBody2D,
	target_tile,
	target_egg,
	wander_target: Vector2,
	move_speed: float
) -> String:
	var target = target_tile if target_tile else (target_egg.global_position if target_egg else wander_target)
	var direction = (target - self_node.global_position).normalized()
	self_node.velocity = direction * move_speed
	self_node.move_and_slide()

	if self_node.global_position.distance_to(target) < 5.0:
		if target_tile:
			return "tile"
		elif target_egg:
			return "egg"
		else:
			return "wander"
	return ""
