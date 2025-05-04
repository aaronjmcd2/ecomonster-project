# DragonTileModule.gd
# Handles Dragon-specific tile operations
# Focuses on lava-to-soil and ice-to-soil conversion

extends Node

# Converts lava or ice to soil at the given position
# Returns the original source_id if conversion happened, -1 otherwise
func convert_to_soil(dragon: Node, tile_pos: Vector2i, tile_map_layer: TileMapLayer) -> int:
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	
	# Only convert lava (2) or ice (4) to soil (3)
	if source_id == 2 or source_id == 4:
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Convert to soil
		TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
		tile_map_layer.fix_invalid_tiles()
		return source_id  # Return the original type
	
	return -1  # No conversion happened

# Processes the specific resource gathered based on the source_id
# Updates dragon's storage and excretion state
func process_resource(dragon: Node, source_id: int) -> void:
	match source_id:
		2:  # Lava
			dragon.lava_storage += 1
			if dragon.lava_storage >= dragon.required_lava_to_excrete and not dragon.is_cooling_down:
				dragon.is_cooling_down = true
				dragon.cooldown_timer = dragon.cooldown_time
				dragon.excretion_type = "lava"
		
		4:  # Ice
			dragon.ice_storage += 1
			if dragon.ice_storage >= dragon.required_ice_to_excrete and not dragon.is_cooling_down:
				dragon.is_cooling_down = true
				dragon.cooldown_timer = dragon.cooldown_time
				dragon.excretion_type = "ice"

# Remove target from the claimed positions list
func release_tile(tile_pos: Vector2) -> void:
	if tile_pos in SearchModule.claimed_tile_positions:
		SearchModule.claimed_tile_positions.erase(tile_pos)
