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
			
		var info = {
			"name": "Dragon",
			"efficiency": int(float(dragon.lava_storage) / float(dragon.max_lava_storage) * 100.0),
			"stats": "Lava Stored: %d/%d\nOre Output: %d\n%s" % [
				dragon.lava_storage, dragon.max_lava_storage, dragon.ore_drop_count, cooldown_display
			],
			"node": dragon
		}
		MonsterInfo.show_info(info, event.position)
