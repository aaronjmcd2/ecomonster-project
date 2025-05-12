# SpecterUIModule.gd
# Handles UI interactions for the Specter
extends Node

# Process clicks on the Specter
func handle_input_event(specter: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var stats = specter.get_live_stats()
		var info = {
			"name": stats.name,
			"efficiency": stats.efficiency,
			"stats": stats.stats,
			"node": specter
		}
		MonsterInfo.show_info(info, event.position)
