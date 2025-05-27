# SpiderMovementModule.gd
# Handles movement toward targets and wandering

extends Node

# Move toward the current target
# Returns true if reached target
func move_toward_target(spider: Node, target_data: Dictionary, move_speed: float) -> bool:
	if not target_data.target:
		return false
	
	# Get target position based on type
	var target_pos = Vector2.ZERO
	match target_data.type:
		"drop":
			if is_instance_valid(target_data.target):
				target_pos = target_data.target.global_position
			else:
				return false
	
	var direction = (target_pos - spider.global_position).normalized()
	spider.velocity = direction * move_speed
	spider.move_and_slide()
	
	# Check if reached target
	if spider.global_position.distance_to(target_pos) < 4.0:
		return true
	
	return false

# Move toward wander target
func move_toward_wander_target(spider: Node, wander_target: Vector2, move_speed: float) -> void:
	var direction = (wander_target - spider.global_position).normalized()
	spider.velocity = direction * move_speed
	spider.move_and_slide()

# Pick a new wander target
func pick_wander_target(spider_position: Vector2) -> Vector2:
	var wander_distance = randf_range(64.0, 160.0)
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * wander_distance
	return spider_position + offset
