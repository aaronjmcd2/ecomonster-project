# DragonStatsModule.gd
# Handles efficiency tracking and stat calculations for Dragon

extends Node

func update_efficiency(dragon: Node, delta: float, is_efficient: bool) -> void:
	if is_efficient:
		dragon.efficiency_score += dragon.EFFICIENCY_RATE * delta
	else:
		dragon.efficiency_score -= dragon.EFFICIENCY_RATE * delta

	dragon.efficiency_score = clamp(dragon.efficiency_score, 0.0, 100.0)

func update_ore_log(dragon: Node, delta: float) -> void:
	dragon.ore_timer += delta
	if dragon.ore_timer >= 1.0:
		dragon.ore_log.append(dragon.ore_this_second)
		if dragon.ore_log.size() > dragon.ORE_LOG_SIZE:
			dragon.ore_log.pop_front()

		dragon.ore_this_second = 0
		dragon.ore_timer = 0.0

func get_live_stats(dragon: Node) -> Dictionary:
	var total_stored = dragon.get_total_storage()
	var efficiency_pct = int(dragon.efficiency_score)

	var next_output = "None"
	var next_output_count = 0

	if dragon.excretion_type == "lava":
		next_output = "Iron Ore"
		next_output_count = int(dragon.lava_storage / dragon.required_lava_to_excrete) * dragon.lava_yield
	elif dragon.excretion_type == "ice":
		next_output = "Silver Ore"
		next_output_count = int(dragon.ice_storage / dragon.required_ice_to_excrete) * dragon.ice_yield
	elif dragon.excretion_type == "egg":
		next_output = "Gold Ore"
		next_output_count = int(dragon.egg_storage / dragon.required_eggs_to_excrete) * dragon.egg_yield

	var stat_text = "Storage: %d / %d\n" % [total_stored, dragon.max_total_storage]
	stat_text += "- Lava: %d (%d needed → %d Iron Ore)\n" % [dragon.lava_storage, dragon.required_lava_to_excrete, dragon.lava_yield]
	stat_text += "- Ice: %d (%d needed → %d Silver Ore)\n" % [dragon.ice_storage, dragon.required_ice_to_excrete, dragon.ice_yield]
	stat_text += "- Eggs: %d (%d needed → %d Gold Ore)\n" % [dragon.egg_storage, dragon.required_eggs_to_excrete, dragon.egg_yield]
	stat_text += "Cooldown: %.1f sec\n" % dragon.cooldown_time
	stat_text += "Next Output: %s x%d" % [next_output, next_output_count]

	return {
		"efficiency": efficiency_pct,
		"stats": stat_text
	}
