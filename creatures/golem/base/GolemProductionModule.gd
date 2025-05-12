# GolemProductionModule.gd
# Handles the production of ingots and concrete for the Golem

extends Node

# Determine which output to produce based on available resources
func determine_production_type(golem: Node) -> String:
	# Check each recipe in priority order
	if golem.lava_storage >= golem.lava_required:
		# Check materials in priority order
		if golem.stone_storage >= golem.material_required:
			return "reinforced_concrete"
		elif golem.iron_ore_storage >= golem.material_required:
			return "iron_ingot"
		elif golem.silver_ore_storage >= golem.material_required:
			return "silver_ingot"
		elif golem.gold_ore_storage >= golem.material_required:
			return "gold_ingot"
		elif golem.aetherdrift_ore_storage >= golem.material_required:
			return "aetherdrift_ingot"
	
	return ""  # Not enough resources for any recipe

# Produce the selected output
func produce_output(golem: Node) -> void:
	# If no production type is set, determine one
	if golem.production_type == "":
		golem.production_type = determine_production_type(golem)
		
		# If still no valid production type, end cooldown
		if golem.production_type == "":
			golem.is_cooling_down = false
			golem.cooldown_timer = 0.0
			return
	
	# Process the recipe
	var drops_to_produce := 0
	var drop_scene: PackedScene = null
	
	match golem.production_type:
		"reinforced_concrete":
			if golem.lava_storage >= golem.lava_required and golem.stone_storage >= golem.material_required:
				drops_to_produce = golem.reinforced_concrete_yield
				golem.lava_storage -= golem.lava_required
				golem.stone_storage -= golem.material_required
				drop_scene = golem.reinforced_concrete_scene
		
		"iron_ingot":
			if golem.lava_storage >= golem.lava_required and golem.iron_ore_storage >= golem.material_required:
				drops_to_produce = golem.iron_ingot_yield
				golem.lava_storage -= golem.lava_required
				golem.iron_ore_storage -= golem.material_required
				drop_scene = golem.iron_ingot_scene
		
		"silver_ingot":
			if golem.lava_storage >= golem.lava_required and golem.silver_ore_storage >= golem.material_required:
				drops_to_produce = golem.silver_ingot_yield
				golem.lava_storage -= golem.lava_required
				golem.silver_ore_storage -= golem.material_required
				drop_scene = golem.silver_ingot_scene
		
		"gold_ingot":
			if golem.lava_storage >= golem.lava_required and golem.gold_ore_storage >= golem.material_required:
				drops_to_produce = golem.gold_ingot_yield
				golem.lava_storage -= golem.lava_required
				golem.gold_ore_storage -= golem.material_required
				drop_scene = golem.gold_ingot_scene
		
		"aetherdrift_ingot":
			if golem.lava_storage >= golem.lava_required and golem.aetherdrift_ore_storage >= golem.material_required:
				drops_to_produce = golem.aetherdrift_ingot_yield
				golem.lava_storage -= golem.lava_required
				golem.aetherdrift_ore_storage -= golem.material_required
				drop_scene = golem.aetherdrift_ingot_scene
	
	# Spawn drops
	if drop_scene and drops_to_produce > 0:
		for i in drops_to_produce:
			var instance = drop_scene.instantiate()
			var offset = Vector2(randi_range(-16, 16), randi_range(-16, 16))
			instance.global_position = golem.global_position + offset
			golem.get_parent().add_child(instance)
			golem.ingots_this_second += 1
	
	# Determine if we can keep producing the same type
	var can_continue = false
	match golem.production_type:
		"reinforced_concrete":
			can_continue = golem.lava_storage >= golem.lava_required and golem.stone_storage >= golem.material_required
		"iron_ingot":
			can_continue = golem.lava_storage >= golem.lava_required and golem.iron_ore_storage >= golem.material_required
		"silver_ingot":
			can_continue = golem.lava_storage >= golem.lava_required and golem.silver_ore_storage >= golem.material_required
		"gold_ingot":
			can_continue = golem.lava_storage >= golem.lava_required and golem.gold_ore_storage >= golem.material_required
		"aetherdrift_ingot":
			can_continue = golem.lava_storage >= golem.lava_required and golem.aetherdrift_ore_storage >= golem.material_required
	
	# If we can continue with the same recipe, reset cooldown
	if can_continue:
		golem.cooldown_timer = golem.cooldown_time
		return
	
	# Try to switch to a different recipe
	golem.production_type = determine_production_type(golem)
	
	# If we found a new recipe, reset cooldown
	if golem.production_type != "":
		golem.cooldown_timer = golem.cooldown_time
		return
	
	# No valid recipes, end cooldown
	golem.is_cooling_down = false
	golem.cooldown_timer = 0.0
	golem.production_type = ""
