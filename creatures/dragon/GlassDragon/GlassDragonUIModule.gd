# GlassDragonUIModule.gd
# Handles UI interactions for the Glass Dragon
# Primarily interacts with MonsterInfo for click events

extends Node

# Handles mouse click on Glass Dragon
# Displays info popup with monster stats
func handle_input_event(dragon: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Format the timer display
		var cooldown_display = ""
		if dragon.is_cooling_down:
			cooldown_display = "Cooldown: %.1f / %.1f sec" % [dragon.cooldown_timer, dragon.cooldown_time]
		else:
			cooldown_display = "Cooldown: Ready"
		
		# Determine glass type based on resource balance
		var glass_type = "Regular Glass"
		if dragon.lava_storage > dragon.ice_storage:
			glass_type = "Tempered Glass"
			
		var info = {
			"name": "Glass Dragon",
			"efficiency": int(dragon.efficiency_score),
			"stats": "Lava Stored: %d/%d\nIce Stored: %d/%d\nProducing: %s\n%s" % [
				dragon.lava_storage, dragon.max_lava_storage,
				dragon.ice_storage, dragon.max_lava_storage,
				glass_type, cooldown_display
			],
			"node": dragon
		}
		MonsterInfo.show_info(info, event.position)
