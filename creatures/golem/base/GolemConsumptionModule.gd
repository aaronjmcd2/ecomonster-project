# GolemConsumptionModule.gd
# Handles resource consumption for the Golem

extends Node

# Update the GolemConsumptionModule.gd functions

# Consume lava from a tile
func consume_lava(golem: Node, target_tile, tile_map_layer: TileMapLayer) -> void:
	if golem.is_lava_storage_full():
		return
	
	if not target_tile:
		return
	
	var tile_pos = tile_map_layer.local_to_map(target_tile)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	
	if source_id == 2:  # Lava
		# Convert to soil
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # 3 = Soil
		TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
		
		# Add to storage
		golem.lava_storage += 1
		
		# Check if we can start production
		if not golem.is_cooling_down and _can_start_production(golem):
			golem.is_cooling_down = true
			golem.cooldown_timer = golem.cooldown_time
			golem.production_type = golem.production_module.determine_production_type(golem)
	
	# Release claim on tile
	if target_tile in SearchModule.claimed_tile_positions:
		SearchModule.claimed_tile_positions.erase(target_tile)

# Consume material from a resource
func consume_material(golem: Node, target_material: Node, material_type: String) -> void:
	if golem.is_material_storage_full():
		return
	
	if not target_material or not is_instance_valid(target_material):
		return
	
	# Increase appropriate storage based on material type
	match material_type:
		"stone":
			golem.stone_storage += 1
		"iron":
			golem.iron_ore_storage += 1
		"silver":
			golem.silver_ore_storage += 1
		"gold":
			golem.gold_ore_storage += 1
		"aetherdrift":
			golem.aetherdrift_ore_storage += 1
	
	# Remove the resource from the scene
	if target_material.is_inside_tree():
		if target_material.claimed_by == golem:
			target_material.claimed_by = null
		target_material.queue_free()
	
	# Check if we can start production
	if not golem.is_cooling_down and _can_start_production(golem):
		golem.is_cooling_down = true
		golem.cooldown_timer = golem.cooldown_time
		golem.production_type = golem.production_module.determine_production_type(golem)

# Check if we have enough resources to start any production
func _can_start_production(golem: Node) -> bool:
	if golem.lava_storage < golem.lava_required:
		return false
	
	# Check if we have any valid material
	return (
		golem.stone_storage >= golem.material_required or
		golem.iron_ore_storage >= golem.material_required or
		golem.silver_ore_storage >= golem.material_required or
		golem.gold_ore_storage >= golem.material_required or
		golem.aetherdrift_ore_storage >= golem.material_required
	)
