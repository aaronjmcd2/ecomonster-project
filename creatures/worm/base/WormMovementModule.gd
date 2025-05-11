# CoalWormMovementModule.gd
# Handles movement toward target ore drops

extends Node

# Move toward target drop
# Returns: true if reached target, false otherwise
func move_toward_target(worm: Node, target_drop: Node, speed: float, delta: float) -> bool:
	if target_drop == null or not is_instance_valid(target_drop):
		return false
	
	var target_pos = target_drop.global_position
	var direction = (target_pos - worm.global_position).normalized()
	worm.move_vector = direction * speed
	worm.velocity = worm.move_vector
	worm.move_and_slide()
	
	# Check if reached target
	if worm.global_position.distance_to(target_pos) < 5.0:
		return true
	
	return false
