# CoalWormSearchModule.gd
# Handles search functionality for Coal Worm
# Wraps the existing WormSearchModule

extends Node

# Find closest iron ore drop within search radius
func find_target_drop(worm: Node) -> Node2D:
	return WormSearchModule.find_closest_iron_drop(
		worm.global_position, 
		worm.search_radius * 64.0, 
		worm
	)
