# DragonSearchModule.gd
# Handles search functionality for the Dragon monster
# Finds lava tiles and sets wander target if none found

extends Node

# Searches for lava tile within the given radius
# Returns: Vector2 position or null if none found
func search_for_lava(dragon: Node) -> Variant:
	var target = SearchModule.find_nearest_tile(dragon.global_position, dragon.search_radius_tiles, 2)
	if not target:
		# This is key - always ensure we have a wander target if no lava is found
		if dragon.wander_target == Vector2.ZERO or dragon.global_position.distance_to(dragon.wander_target) < 5.0:
			dragon.wander_target = dragon.wander_module.pick_wander_target(dragon.global_position)
		return null
	
	return target

# Helper function to ensure we always have a valid wander target
# Call this when no resources are found
func ensure_wander_target(dragon: Node) -> void:
	if dragon.wander_target == Vector2.ZERO or dragon.global_position.distance_to(dragon.wander_target) < 5.0:
		dragon.wander_target = dragon.wander_module.pick_wander_target(dragon.global_position)
