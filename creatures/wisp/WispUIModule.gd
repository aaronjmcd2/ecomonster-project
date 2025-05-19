# WispUIModule.gd
# Handles UI interactions for the Wisp
extends Node

# Process clicks on the Wisp
func handle_input_event(wisp: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var stats = wisp.get_live_stats()
		var info = {
			"name": stats.name,
			"efficiency": stats.efficiency,
			"stats": stats.stats,
			"node": wisp
		}
		MonsterInfo.show_info(info, event.position)
