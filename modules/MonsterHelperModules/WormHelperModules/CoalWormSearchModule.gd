# CoalWormSearchModule.gd
# Enhanced to find multiple types of resources

extends Node

# Find target based on priority: iron drops -> crystals -> melons
func find_target(worm: Node) -> Dictionary:
	# First try iron drops (original behavior)
	var iron_drop = find_target_drop(worm)
	if iron_drop:
		return {"type": "drop", "target": iron_drop, "resource_type": "iron"}
	
	return {"type": "none", "target": null, "resource_type": ""}

# Original function for backward compatibility
func find_target_drop(worm: Node) -> Node2D:
	return WormSearchModule.find_closest_iron_drop(
		worm.global_position, 
		worm.search_radius * 64.0, 
		worm
	)
