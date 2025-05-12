# SpecterMovementModule.gd
# Handles floating movement for Specters
extends Node

var time_passed: float = 0.0
var vertical_offset: float = 0.0

# Float toward a target with ghostly movement
func float_toward_target(delta: float, self_node: CharacterBody2D, target: Vector2, move_speed: float) -> String:
	# Update bobbing motion
	time_passed += delta
	vertical_offset = sin(time_passed * 2.0) * 10.0
	
	# Calculate base direction
	var direction = (target - self_node.global_position).normalized()
	
	# Add some random wobble
	var wobble = Vector2(
		sin(time_passed * 3.0) * 0.2,
		cos(time_passed * 2.5) * 0.2
	)
	
	# Calculate velocity with wobble
	self_node.velocity = (direction + wobble).normalized() * move_speed
	
	# Apply vertical offset
	self_node.position.y += vertical_offset * delta
	
	# Move character
	self_node.move_and_slide()
	
	# Check if reached target
	if self_node.global_position.distance_to(target) < 50.0:
		return "reached"
	
	return "moving"
