# WispMovementModule.gd (simplified)
extends Node

var time_passed: float = 0.0

# Float toward a target with ethereal wisp movement
func float_toward_target(delta: float, self_node: CharacterBody2D, target: Vector2, move_speed: float) -> String:
	# Update time tracking for wobble effect
	time_passed += delta
	
	# Calculate base direction
	var direction = (target - self_node.global_position).normalized()
	
	# Add some simple wobble
	var wobble = Vector2(
		sin(time_passed * 3.0) * 0.2,
		cos(time_passed * 2.5) * 0.2
	)
	
	# Calculate velocity with wobble
	self_node.velocity = (direction + wobble).normalized() * move_speed
	
	# Move character
	self_node.move_and_slide()
	
	# Check if reached target
	if self_node.global_position.distance_to(target) < 50.0:
		return "reached"
	
	return "moving"
