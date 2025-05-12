# GolemSearchModule.gd
# Handles search functionality for the Golem

extends Node

# Search for lava and material resources
func search_for_resources(golem: Node) -> bool:
	# First search for lava if needed
	if golem.lava_storage < golem.lava_required and not golem.target_lava:
		golem.target_lava = search_for_lava(golem)
	
	# Then search for other materials based on what we have and priority
	if not golem.target_material:
		# Check each material in priority order
		if golem.stone_storage < golem.material_required:
			golem.target_material = search_for_stone(golem)
			if golem.target_material:
				golem.material_type = "stone"
		
		if not golem.target_material and golem.iron_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "iron")
			if golem.target_material:
				golem.material_type = "iron"
		
		if not golem.target_material and golem.silver_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "silver")
			if golem.target_material:
				golem.material_type = "silver"
		
		if not golem.target_material and golem.gold_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "gold")
			if golem.target_material:
				golem.material_type = "gold"
		
		if not golem.target_material and golem.aetherdrift_ore_storage < golem.material_required:
			golem.target_material = search_for_ore(golem, "aetherdrift")
			if golem.target_material:
				golem.material_type = "aetherdrift"
	
	return golem.target_lava != null or golem.target_material != null

# Search for lava tiles
func search_for_lava(golem: Node) -> Variant:
	return SearchModule.find_nearest_tile(
		golem.global_position,
		golem.search_radius_tiles,
		2  # Lava source ID is 2
	)

# Search for stone drops
func search_for_stone(golem: Node) -> Node2D:
	# First try to find stones using safe method
	for drop in golem.get_tree().get_nodes_in_group("stone_drops"):
		if not is_instance_valid(drop):
			continue
			
		# Safe way to check and set claimed_by
		var already_claimed = false
		if drop.has_method("get") and drop.has_method("set"):
			already_claimed = drop.get("claimed_by") != null and drop.get("claimed_by") != golem
		elif drop.has_variable("claimed_by"):
			already_claimed = drop.claimed_by != null and drop.claimed_by != golem
			
		if already_claimed:
			continue
			
		var dist = golem.global_position.distance_to(drop.global_position)
		if dist <= golem.search_radius_px:
			# Safe way to claim
			if drop.has_method("set"):
				drop.set("claimed_by", golem)
			elif drop.has_variable("claimed_by"):
				drop.claimed_by = golem
				
			return drop
	
	return null

# Search for various ore drops
func search_for_ore(golem: Node, ore_type: String) -> Node2D:
	var target = null
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
			if drop.has_variable("resource_type"):
				if drop.resource_type != "iron":
					continue
			else:
				# Skip if we can't determine the type
				continue
		
		# Safe way to check and set claimed_by
		var already_claimed = false
		if drop.has_method("get") and drop.has_method("set"):
			already_claimed = drop.get("claimed_by") != null and drop.get("claimed_by") != golem
		elif drop.has_variable("claimed_by"):
			already_claimed = drop.claimed_by != null and drop.claimed_by != golem
			
		if already_claimed:
			continue
			
		var dist = golem.global_position.distance_to(drop.global_position)
		if dist <= golem.search_radius_px:
			# Safe way to claim
			if drop.has_method("set"):
				drop.set("claimed_by", golem)
			elif drop.has_variable("claimed_by"):
				drop.claimed_by = golem
				
			print("🔖 " + ore_type.capitalize() + " drop claimed by:", golem.name)
			return drop
	
	return null
