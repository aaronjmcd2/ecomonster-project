# GlassDragonStatsModule.gd
# Handles efficiency tracking and stat calculations for Glass Dragon

extends Node

func update_efficiency(dragon: Node, delta: float, is_efficient: bool) -> void:
	if is_efficient:
		dragon.efficiency_score += dragon.EFFICIENCY_RATE * delta
	else:
		dragon.efficiency_score -= dragon.EFFICIENCY_RATE * delta

	dragon.efficiency_score = clamp(dragon.efficiency_score, 0.0, 100.0)

func update_glass_log(dragon: Node, delta: float) -> void:
	dragon.glass_timer += delta
	if dragon.glass_timer >= 1.0:
		dragon.glass_log.append(dragon.glass_this_second)
		if dragon.glass_log.size() > dragon.GLASS_LOG_SIZE:
			dragon.glass_log.pop_front()

		dragon.glass_this_second = 0
		dragon.glass_timer = 0.0

func get_live_stats(dragon: Node) -> Dictionary:
	var total_stored = dragon.get_total_storage()
	var efficiency_pct = int(dragon.efficiency_score)
	var balance_ratio = 0.0
	
	if dragon.lava_storage > 0 and dragon.ice_storage > 0:
		var max_val = max(dragon.lava_storage, dragon.ice_storage)
		var min_val = min(dragon.lava_storage, dragon.ice_storage)
		balance_ratio = float(min_val) / float(max_val) * 100.0
	
	var glass_type = "Regular Glass"
	if dragon.lava_storage > dragon.ice_storage:
		glass_type = "Tempered Glass"
		
	var next_output_count = 0
	if dragon.lava_storage >= dragon.required_lava_to_excrete and dragon.ice_storage >= dragon.required_ice_to_excrete:
		next_output_count = dragon.glass_yield

	# Format the cooldown timer display
	var cooldown_display = ""
	if dragon.is_cooling_down:
		cooldown_display = "Cooldown: %.1f / %.1f sec" % [dragon.cooldown_timer, dragon.cooldown_time]
	else:
		cooldown_display = "Cooldown: Ready"

	var stat_text = "Storage: %d / %d\n" % [total_stored, dragon.max_total_storage]
	stat_text += "- Lava: %d (%d needed for glass)\n" % [dragon.lava_storage, dragon.required_lava_to_excrete]
	stat_text += "- Ice: %d (%d needed for glass)\n" % [dragon.ice_storage, dragon.required_ice_to_excrete]
	stat_text += cooldown_display + "\n"
	stat_text += "Next Output: %s x%d\n" % [glass_type, next_output_count]
	stat_text += "Balance Ratio: %d%%" % [int(balance_ratio)]

	return {
		"efficiency": efficiency_pct,
		"stats": stat_text
	}
