# CoalWormSearchModule.gd
# Enhanced to find multiple types of resources

extends Node

# Find target based on priority: iron drops -> boulders
func find_target(worm: Node) -> Dictionary:
	# First try iron drops (original behavior)
	var iron_drop = find_target_drop(worm)
	if iron_drop:
		return {"type": "drop", "target": iron_drop, "resource_type": "iron"}
	
	# Try to find boulder
	var boulder = _find_nearest_boulder(worm)
	if boulder:
		return {"type": "entity", "target": boulder, "resource_type": "boulder"}
	
	return {"type": "none", "target": null, "resource_type": ""}

# Original function for backward compatibility
func find_target_drop(worm: Node) -> Node2D:
	return WormSearchModule.find_closest_iron_drop(
		worm.global_position, 
		worm.search_radius * 64.0, 
		worm
	)

# Find nearest boulder
func _find_nearest_boulder(worm: Node) -> Node:
	var closest = null
	var closest_dist = worm.search_radius * 64.0
	
	var tree = worm.get_tree()
	if not tree:
		return null
		
	for boulder in tree.get_nodes_in_group("boulders"):
		if boulder.claimed_by != null and boulder.claimed_by != worm:
			continue
			
		var dist = worm.global_position.distance_to(boulder.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = boulder
	
	if closest:
		closest.claimed_by = worm
	
	return closest
