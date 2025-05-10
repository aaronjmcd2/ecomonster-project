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
	var target
	var target_type = "none"
	
	# Determine target, prioritizing tile > egg > wander
	if target_tile:
		target = target_tile
		target_type = "tile"
	elif target_egg:
		target = target_egg.global_position
		target_type = "egg"
	elif wander_target != Vector2.ZERO:
		target = wander_target
		target_type = "wander"
	else:
		# No target at all
		self_node.velocity = Vector2.ZERO
		return ""
	
	var direction = (target - self_node.global_position).normalized()
	self_node.velocity = direction * move_speed
	self_node.move_and_slide()

	# Check if we've arrived at the target
	if self_node.global_position.distance_to(target) < 5.0:
		if target_type == "tile":
			return "tile"
		elif target_type == "egg":
			return "egg"
		else:
			return "wander"
	
	# Still moving
	return ""
