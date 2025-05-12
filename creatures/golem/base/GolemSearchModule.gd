# GolemSearchModule.gd
# Handles search functionality for the Golem

extends Node

# Search for lava and material resources
# Search for lava and material resources
func search_for_resources(golem: Node) -> bool:
	var found_target = false
	
	# First search for lava if needed and not already having a lava target
	if not golem.is_lava_storage_full() and not golem.target_lava:
		golem.target_lava = search_for_lava(golem)
		if golem.target_lava:
			found_target = true
	
	# Then search for materials if there's storage space and no material target
	if not golem.is_material_storage_full() and not golem.target_material:
		# Check each material in priority order
		if golem.stone_storage < golem.material_required:
			golem.target_material = search_for_stone(golem)
			if golem.target_material:
				golem.material_type = "stone"
				found_target = true
		
		if not golem.target_material and golem.iron_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "iron")
			if golem.target_material:
				golem.material_type = "iron"
				found_target = true
		
		if not golem.target_material and golem.silver_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "silver")
			if golem.target_material:
				golem.material_type = "silver"
				found_target = true
		
		if not golem.target_material and golem.gold_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "gold")
			if golem.target_material:
				golem.material_type = "gold"
				found_target = true
		
		if not golem.target_material and golem.aetherdrift_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "aetherdrift")
			if golem.target_material:
				golem.material_type = "aetherdrift"
				found_target = true
	
	return found_target

# Search for lava tiles
func search_for_lava(golem: Node) -> Variant:
	return SearchModule.find_nearest_tile(
		golem.global_position,
		golem.search_radius_tiles,
		2  # Lava source ID is 2
	)

# Search for stone drops
func search_for_stone(golem: Node) -> Node2D:
	for drop in golem.get_tree().get_nodes_in_group("stone_drops"):
		if not is_instance_valid(drop):
			continue
			
		# Safe way to check claimed_by
		var already_claimed = false
		if drop.get("claimed_by") != null and drop.get("claimed_by") != golem:
			already_claimed = true
			
		if already_claimed:
			continue
			
		var dist = golem.global_position.distance_to(drop.global_position)
		if dist <= golem.search_radius_px:
			# Safe way to set claimed_by
			drop.claimed_by = golem
			return drop
	
	return null

# Search for various ore drops
func search_for_ore(golem: Node, ore_type: String) -> Node2D:
	var group_name = ""
	
	match ore_type:
		"iron":
			group_name = "ore_drops"
		"silver":
			group_name = "silver_ore_drops"
		"gold":
			group_name = "gold_ore_drops"
		"aetherdrift":
			group_name = "aetherdrift_ore_drops"
	
	# Safety check
	if group_name == "":
		return null
	
	for drop in golem.get_tree().get_nodes_in_group(group_name):
		if not is_instance_valid(drop):
			continue
		
		# For "ore_drops" group, filter by resource_type
		if group_name == "ore_drops" and ore_type == "iron":
			if drop.get("resource_type") != "iron":
				continue
		
		# Safe way to check claimed_by
		if drop.get("claimed_by") != null and drop.get("claimed_by") != golem:
			continue
			
		var dist = golem.global_position.distance_to(drop.global_position)
		if dist <= golem.search_radius_px:
			# Safe way to set claimed_by
			drop.claimed_by = golem
			print("🔖 " + ore_type.capitalize() + " drop claimed by:", golem.name)
			return drop
	
	return null
