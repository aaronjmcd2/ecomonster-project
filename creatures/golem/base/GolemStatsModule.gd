# GolemStatsModule.gd
# Handles efficiency and stats tracking for the Golem

extends Node

# Update efficiency score
func update_efficiency(golem: Node, delta: float, is_efficient: bool) -> void:
	if is_efficient:
		golem.efficiency_score += golem.EFFICIENCY_RATE * delta
	else:
		golem.efficiency_score -= golem.EFFICIENCY_RATE * delta
	
	golem.efficiency_score = clamp(golem.efficiency_score, 0.0, 100.0)

# Update ingot production log
func update_ingot_log(golem: Node, delta: float) -> void:
	golem.ingot_timer += delta
	if golem.ingot_timer >= 1.0:
		golem.ingot_log.append(golem.ingots_this_second)
		if golem.ingot_log.size() > golem.INGOT_LOG_SIZE:
			golem.ingot_log.pop_front()
		
		golem.ingots_this_second = 0
		golem.ingot_timer = 0.0

# Get stats for display
func get_live_stats(golem: Node) -> Dictionary:
	var lava_stored = golem.lava_storage
	var materials_stored = golem.get_total_material_storage()
	var efficiency_pct = int(golem.efficiency_score)
	
	var next_output = "None"
	var next_output_count = 0
	
	# Determine next output type and count
	match golem.production_type:
		"reinforced_concrete":
			next_output = "Reinforced Concrete"
			next_output_count = golem.reinforced_concrete_yield
		"iron_ingot":
			next_output = "Iron Ingots"
			next_output_count = golem.iron_ingot_yield
		"silver_ingot":
			next_output = "Silver Ingots"
			next_output_count = golem.silver_ingot_yield
		"gold_ingot":
			next_output = "Gold Ingots"
			next_output_count = golem.gold_ingot_yield
		"aetherdrift_ingot":
			next_output = "Aetherdrift Ingots"
			next_output_count = golem.aetherdrift_ingot_yield
	
	# Format cooldown timer display
	var cooldown_display = ""
	if golem.is_cooling_down:
		cooldown_display = "Cooldown: %.1f / %.1f sec" % [golem.cooldown_timer, golem.cooldown_time]
	else:
		cooldown_display = "Cooldown: Ready"
	
	# Build stats text with separate storage displays
	var stat_text = "Lava Storage: %d / %d\n" % [lava_stored, golem.max_lava_storage]
	stat_text += "Material Storage: %d / %d\n" % [materials_stored, golem.max_material_storage] 
	stat_text += "- Stone: %d\n" % golem.stone_storage
	stat_text += "- Iron Ore: %d\n" % golem.iron_ore_storage
	stat_text += "- Silver Ore: %d\n" % golem.silver_ore_storage
	stat_text += "- Gold Ore: %d\n" % golem.gold_ore_storage
	stat_text += "- Aetherdrift Ore: %d\n" % golem.aetherdrift_ore_storage
	stat_text += cooldown_display + "\n"
	stat_text += "Next Output: %s x%d" % [next_output, next_output_count]
	
	return {
		"efficiency": efficiency_pct,
		"stats": stat_text
	}
