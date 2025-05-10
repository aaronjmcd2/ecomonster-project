# DragonSearchModule.gd
# Handles search functionality for the Dragon monster
# Finds lava, ice tiles, and egg drops

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

# Searches for ice tile within the given radius
# Returns: Vector2 position or null if none found
func search_for_ice(dragon: Node) -> Variant:
	return SearchModule.find_nearest_tile(dragon.global_position, dragon.search_radius_tiles, 4)

# Searches for egg drop within the given pixel radius
# Returns: Node2D or null if none found
func search_for_egg(dragon: Node) -> Variant:
	return SearchModule.find_closest_drop_of_type(dragon.global_position, dragon.search_radius_px, "egg", dragon)

# Performs a complete resource search for the dragon
# Updates target_tile and target_egg as needed
# Returns: true if any target was found
func search_for_resources(dragon: Node) -> bool:
	# First try to find lava
	dragon.target_tile = search_for_lava(dragon)
	
	# If no lava, try to find ice
	if not dragon.target_tile:
		dragon.target_tile = search_for_ice(dragon)
	
	# If no tiles and no egg currently targeted, try to find egg
	if not dragon.target_tile and not dragon.target_egg:
		dragon.target_egg = search_for_egg(dragon)
	
	return dragon.target_tile != null or dragon.target_egg != null

# Helper function to ensure we always have a valid wander target
# Call this when no resources are found
func ensure_wander_target(dragon: Node) -> void:
	if dragon.wander_target == Vector2.ZERO or dragon.global_position.distance_to(dragon.wander_target) < 5.0:
		dragon.wander_target = dragon.wander_module.pick_wander_target(dragon.global_position)
