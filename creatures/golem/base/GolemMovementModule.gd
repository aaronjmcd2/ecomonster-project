# GolemMovementModule.gd
# Handles movement toward targets for the Golem

extends Node

# Move toward a specific target
func move_toward_target(delta: float, golem: Node, target, target_type: String, move_speed: float) -> String:
	var target_pos: Vector2
	
	# Get the target position based on type
	if target_type == "lava":
		target_pos = target  # Already a Vector2
	else:
		# For material resources, get their global position
		if is_instance_valid(target):
			target_pos = target.global_position
		else:
			return "invalid"
	
	# Calculate direction and move
	var direction = (target_pos - golem.global_position).normalized()
	golem.velocity = direction * move_speed
	golem.move_and_slide()
	
	# Check if reached target
	if golem.global_position.distance_to(target_pos) < 10.0:
		return "reached"
	
	return "moving"

# Move toward a specific position (used for wandering)
func move_toward_position(delta: float, golem: Node, position: Vector2, move_speed: float) -> String:
	var direction = (position - golem.global_position).normalized()
	golem.velocity = direction * move_speed
	golem.move_and_slide()
	
	# Check if reached position
	if golem.global_position.distance_to(position) < 10.0:
		return "reached"
	
	return "moving"
