# FireElementalConversionModule.gd
extends Node

# Convert based on resource type
func convert_resource(elemental: Node, target_data: Dictionary) -> void:
	match target_data.resource_type:
		"coal":
			# Original behavior - coal to lava
			ConversionModule.replace_tile(target_data.target, 0, 2)  # 0 = Coal, 2 = Lava
			SearchModule.claimed_tile_positions.erase(target_data.target)
			
		"crystal":
			# Crystal to ice
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 4, Vector2i(0, 0))  # 4 = Ice
			target_data.target.consume()
			print("❄️ Fire Elemental converted crystal to ice at", tile_pos)
			
		"melon":
			# Melon to water
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 5, Vector2i(0, 0))  # 5 = Water
			target_data.target.harvest(true)  # true = consumed by monster
			print("💧 Fire Elemental converted melon to water at", tile_pos)
