# FireElementalSearchModule.gd
# Handles search functionality for Fire Elemental

extends Node

# Search for targets in priority order
func search_for_target(elemental: Node) -> Dictionary:
	# First try coal drops (new behavior - prioritize drops over tiles)
	var coal_drop = _find_nearest_coal_drop(elemental)
	if coal_drop:
		return {"type": "entity", "target": coal_drop, "resource_type": "coal_drop"}
	
	# Then try coal tiles (original behavior)
	var result = SearchModule.find_nearest_tile(elemental.global_position, elemental.search_radius, 0)  # 0 = coal
	if result:
		return {"type": "tile", "target": result, "resource_type": "coal"}
	
	# Try to find crystal
	var crystal = _find_nearest_crystal(elemental)
	if crystal:
		return {"type": "entity", "target": crystal, "resource_type": "crystal"}
	
	# Try to find melon
	var melon = _find_nearest_melon(elemental)
	if melon:
		return {"type": "entity", "target": melon, "resource_type": "melon"}
	
	return {"type": "none", "target": null, "resource_type": ""}

# Find nearest crystal
func _find_nearest_crystal(elemental: Node) -> Node:
	var closest = null
	var closest_dist = elemental.search_radius * 32.0
	
	var tree = elemental.get_tree()
	if not tree:
		return null
		
	for crystal in tree.get_nodes_in_group("crystals"):
		if crystal.claimed_by != null and crystal.claimed_by != elemental:
			continue
			
		var dist = elemental.global_position.distance_to(crystal.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = crystal
	
	if closest:
		closest.claimed_by = elemental
	
	return closest

# Find nearest melon
func _find_nearest_melon(elemental: Node) -> Node:
	var closest = null
	var closest_dist = elemental.search_radius * 32.0
	
	var tree = elemental.get_tree()
	if not tree:
		return null
		
	for melon in tree.get_nodes_in_group("melons"):
		if not melon.is_harvestable or (melon.claimed_by != null and melon.claimed_by != elemental):
			continue
			
		var dist = elemental.global_position.distance_to(melon.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = melon
	
	if closest:
		closest.claimed_by = elemental
	
	return closest

# Find nearest coal drop
func _find_nearest_coal_drop(elemental: Node) -> Node:
	var closest = null
	var closest_dist = elemental.search_radius * 32.0
	
	var tree = elemental.get_tree()
	if not tree:
		return null
		
	for coal_drop in tree.get_nodes_in_group("ore_drops"):
		# Check if it's actually a coal drop by checking the item data
		if coal_drop.has_method("get_item_data"):
			var item_data = coal_drop.get_item_data()
			if item_data.name != "Coal":
				continue
		else:
			continue
			
		if coal_drop.claimed_by != null and coal_drop.claimed_by != elemental:
			continue
			
		var dist = elemental.global_position.distance_to(coal_drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = coal_drop
	
	if closest:
		closest.claimed_by = elemental
	
	return closest
