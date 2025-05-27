# SpiderUIModule.gd
# Handles UI interactions for Spider

extends Node

# Handle mouse click on Spider
func handle_input_event(spider: Node, viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var target_str = "None"
		if spider.target_data.target:
			target_str = spider.target_data.resource_type.replace("_", " ").capitalize()
		
		var info = {
			"name": "Spider",
			"efficiency": int(spider.efficiency_score),
			"stats": "Currently Targeting: %s\nCooldown: %.1f seconds" % [target_str, spider.conversion_cooldown],
			"node": spider
		}
		MonsterInfo.show_info(info, event.position)
