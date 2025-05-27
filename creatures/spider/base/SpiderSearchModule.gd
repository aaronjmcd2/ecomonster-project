# SpiderSearchModule.gd
# Handles search functionality for Spider

extends Node

# Search for targets in priority order: Tempered Glass -> Soul
func search_for_target(spider: Node) -> Dictionary:
	# First try tempered glass
	var glass = _find_nearest_tempered_glass(spider)
	if glass:
		return {"type": "drop", "target": glass, "resource_type": "tempered_glass"}
	
	# Try to find soul
	var soul = _find_nearest_soul(spider)
	if soul:
		return {"type": "drop", "target": soul, "resource_type": "soul"}
	
	return {"type": "none", "target": null, "resource_type": ""}

# Find nearest tempered glass
func _find_nearest_tempered_glass(spider: Node) -> Node:
	var closest = null
	var closest_dist = spider.search_radius * 32.0
	
	var tree = spider.get_tree()
	if not tree:
		return null
		
	for glass in tree.get_nodes_in_group("glass_drops"):
		if glass.claimed_by != null and glass.claimed_by != spider:
			continue
			
		var dist = spider.global_position.distance_to(glass.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = glass
	
	if closest:
		closest.claimed_by = spider
	
	return closest

# Find nearest soul
func _find_nearest_soul(spider: Node) -> Node:
	var closest = null
	var closest_dist = spider.search_radius * 32.0
	
	var tree = spider.get_tree()
	if not tree:
		return null
		
	for soul in tree.get_nodes_in_group("soul_drops"):
		if soul.claimed_by != null and soul.claimed_by != spider:
			continue
			
		var dist = spider.global_position.distance_to(soul.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = soul
	
	if closest:
		closest.claimed_by = spider
	
	return closest
