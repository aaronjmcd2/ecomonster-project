# SpiderStatsModule.gd
# Handles efficiency and statistics tracking

extends Node

# Update efficiency score
func update_efficiency(spider: Node, delta: float, was_efficient: bool) -> void:
	spider.efficiency_score = spider.EfficiencyTracker.update(
		delta, 
		was_efficient, 
		spider.efficiency_score, 
		spider.EFFICIENCY_RATE
	)

# Update silk production tracking
func update_silk_tracking(spider: Node, delta: float) -> void:
	spider.silk_tick_timer += delta
	if spider.silk_tick_timer >= 1.0:
		spider.silk_stat.tick()
		spider.silk_tick_timer = 0.0

# Get live stats for display
func get_live_stats(spider: Node) -> Dictionary:
	var average_silk_per_min = spider.silk_stat.get_average()
	var max_silk_per_min = 60.0 / spider.conversion_cooldown

	return {
		"efficiency": int(spider.efficiency_score),
		"stats": "Cooldown: %.1f seconds\nSilk/min: %.1f / %.1f" % [
			spider.conversion_cooldown,
			average_silk_per_min,
			max_silk_per_min
		]
	}
