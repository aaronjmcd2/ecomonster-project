# CoalWormUIModule.gd
# Handles UI interactions for Coal Worm

extends Node

# Handle mouse click on Coal Worm
func handle_input_event(worm: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Coal Worm",
			"efficiency": int(worm.efficiency_score),
			"stats": "Cooldown: %.1f seconds" % worm.cooldown_time,
			"node": worm
		}
		MonsterInfo.show_info(info, event.position)
