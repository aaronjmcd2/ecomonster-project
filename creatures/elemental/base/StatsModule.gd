# FireElementalStatsModule.gd
# Handles efficiency and statistics tracking

extends Node

# Update efficiency score
func update_efficiency(elemental: Node, delta: float, was_efficient: bool) -> void:
	elemental.efficiency_score = elemental.EfficiencyTracker.update(
		delta, 
		was_efficient, 
		elemental.efficiency_score, 
		elemental.EFFICIENCY_RATE
	)

# Update lava production tracking
func update_lava_tracking(elemental: Node, delta: float) -> void:
	elemental.lava_tick_timer += delta
	if elemental.lava_tick_timer >= 1.0:
		elemental.lava_stat.tick()
		elemental.lava_tick_timer = 0.0

# Get live stats for display
func get_live_stats(elemental: Node) -> Dictionary:
	var average_lava_per_min = elemental.lava_stat.get_average()
	var max_lava_per_min = 60.0 / elemental.conversion_cooldown

	return {
		"efficiency": int(elemental.efficiency_score),
		"stats": "Cooldown: %.1f seconds\nLava/min: %.1f / %.1f" % [
			elemental.conversion_cooldown,
			average_lava_per_min,
			max_lava_per_min
		]
	}
