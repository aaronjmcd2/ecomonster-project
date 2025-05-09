# FireElementalConversionModule.gd
# Handles resource conversion

extends Node

# Convert the current target resource
func convert_resource(elemental: Node, target_data: Dictionary) -> void:
	match target_data.resource_type:
		"coal":
			elemental.lava_stat.add(1)
			# Original behavior - coal to lava
			ConversionModule.replace_tile(target_data.target, 0, 2)  # 0 = Coal, 2 = Lava
			SearchModule.claimed_tile_positions.erase(target_data.target)
			
		"crystal":
			# Crystal to ice
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 4, Vector2i(0, 0))  # 4 = Ice
			if target_data.target.has_method("consume"):
				target_data.target.consume()
			print("❄️ Fire Elemental converted crystal to ice at", tile_pos)
			
		"melon":
			# Melon to water
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 5, Vector2i(0, 0))  # 5 = Water
			if target_data.target.has_method("harvest"):
				target_data.target.harvest(true)  # true = consumed by monster
			print("💧 Fire Elemental converted melon to water at", tile_pos)
