# DragonUIModule.gd
# Handles UI interactions for the Dragon
# Primarily interacts with MonsterInfo for click events

extends Node

# Handles mouse click on Dragon
# Displays info popup with monster stats
func handle_input_event(dragon: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Format the timer display
		var cooldown_display = ""
		if dragon.is_cooling_down:
			cooldown_display = "Cooldown: %.1f / %.1f sec" % [dragon.cooldown_timer, dragon.cooldown_time]
		else:
			cooldown_display = "Cooldown: Ready"
		
		# Show evolution progress if tracking lifetime resources
		var evolution_text = ""
		# Check for the variables using get() which is safer
		if dragon.get("total_lava_collected") != null and dragon.get("total_ice_collected") != null:
			evolution_text = "\nEvolution Progress:\n- Lava: %d/%d\n- Ice: %d/%d" % [
				dragon.total_lava_collected, dragon.required_lava_to_evolve,
				dragon.total_ice_collected, dragon.required_ice_to_evolve
			]
		
		var info = {
			"name": "Dragon",
			"efficiency": int(float(dragon.lava_storage) / float(dragon.max_lava_storage) * 100.0),
			"stats": "Lava Stored: %d/%d\nOre Output: %d\n%s%s" % [
				dragon.lava_storage, dragon.max_lava_storage, dragon.ore_drop_count, 
				cooldown_display, evolution_text
			],
			"node": dragon
		}
		MonsterInfo.show_info(info, event.position)
