# FireElementalUIModule.gd
# Handles UI interactions for Fire Elemental

extends Node

# Handle mouse click on Fire Elemental
func handle_input_event(elemental: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var target_str = "None"
		if elemental.target_data.target:
			target_str = elemental.target_data.resource_type.capitalize()
		
		var info = {
			"name": "Fire Elemental",
			"efficiency": int(elemental.efficiency_score),
			"stats": "Currently Targeting: %s\nCooldown: %.1f seconds" % [target_str, elemental.conversion_cooldown],
			"node": elemental
		}
		MonsterInfo.show_info(info, event.position)
