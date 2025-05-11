# CoalWormStatsModule.gd
# Handles efficiency and statistics tracking

extends Node

# Update efficiency score
func update_efficiency(worm: Node, delta: float, was_efficient: bool) -> void:
	worm.efficiency_score = worm.EfficiencyTracker.update(
		delta, 
		was_efficient, 
		worm.efficiency_score, 
		worm.EFFICIENCY_RATE
	)

# Update coal production tracking
func update_coal_tracking(worm: Node, delta: float) -> void:
	worm.coal_tick_timer += delta
	if worm.coal_tick_timer >= 1.0:
		worm.coal_stat.tick()
		worm.coal_tick_timer = 0.0

# Track coal production
func track_coal_produced(worm: Node, amount: int) -> void:
	worm.coal_stat.add(amount)

# Get live stats for display
func get_live_stats(worm: Node) -> Dictionary:
	var average_coal_per_min = worm.coal_stat.get_average()
	var max_coal_per_min = 60.0 / worm.cooldown_time
	return {
		"efficiency": int(worm.efficiency_score),
		"stats": "Cooldown: %.1f seconds\nCoal/min: %.1f / %.1f" % [
			worm.cooldown_time,
			average_coal_per_min,
			max_coal_per_min
		]
	}
