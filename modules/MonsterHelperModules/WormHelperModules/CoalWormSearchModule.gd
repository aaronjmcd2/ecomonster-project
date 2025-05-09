# CoalWormSearchModule.gd
# Enhanced to find multiple types of resources

extends Node

# Find target based on priority: iron drops -> crystals -> melons
func find_target(worm: Node) -> Dictionary:
	# First try iron drops (original behavior)
	var iron_drop = find_target_drop(worm)
	if iron_drop:
		return {"type": "drop", "target": iron_drop, "resource_type": "iron"}
	
	# Try to find crystal
	var crystal = _find_nearest_crystal(worm)
	if crystal:
		return {"type": "entity", "target": crystal, "resource_type": "crystal"}
	
	# Try to find melon
	var melon = _find_nearest_melon(worm)
	if melon:
		return {"type": "entity", "target": melon, "resource_type": "melon"}
	
	return {"type": "none", "target": null, "resource_type": ""}

# Original function for backward compatibility
func find_target_drop(worm: Node) -> Node2D:
	return WormSearchModule.find_closest_iron_drop(
		worm.global_position, 
		worm.search_radius * 64.0, 
		worm
	)

# Find nearest crystal
func _find_nearest_crystal(worm: Node) -> Node:
	var closest = null
	var closest_dist = worm.search_radius * 64.0
	
	# Use the worm's tree instead of get_tree()
	var tree = worm.get_tree()
	if not tree:
		return null
		
	for crystal in tree.get_nodes_in_group("crystals"):
		if crystal.claimed_by != null and crystal.claimed_by != worm:
			continue
			
		var dist = worm.global_position.distance_to(crystal.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = crystal
	
	if closest:
		closest.claimed_by = worm
	
	return closest

# Find nearest melon
func _find_nearest_melon(worm: Node) -> Node:
	var closest = null
	var closest_dist = worm.search_radius * 64.0
	
	# Use the worm's tree instead of get_tree()
	var tree = worm.get_tree()
	if not tree:
		return null
		
	for melon in tree.get_nodes_in_group("melons"):
		if not melon.is_harvestable or (melon.claimed_by != null and melon.claimed_by != worm):
			continue
			
		var dist = worm.global_position.distance_to(melon.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = melon
	
	if closest:
		closest.claimed_by = worm
	
	return closest
