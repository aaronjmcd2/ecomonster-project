# GolemUIModule.gd
# Handles UI interactions for the Golem

extends Node

# Process clicks on the Golem
func handle_input_event(golem: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Golem",
			"efficiency": int(golem.efficiency_score),
			"stats": golem.stats_module.get_live_stats(golem).stats,
			"node": golem
		}
		MonsterInfo.show_info(info, event.position)
