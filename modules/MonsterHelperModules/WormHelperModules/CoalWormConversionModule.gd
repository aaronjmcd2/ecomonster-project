# CoalWormConversionModule.gd
# Enhanced to handle different conversion types

extends Node

# Convert tile based on consumed resource type
func convert_tile_beneath(worm: Node, tile_map_layer: TileMapLayer, resource_type: String = "iron", target_pos: Vector2 = Vector2.ZERO) -> void:
	# Use target position if provided, otherwise use worm position
	var world_pos = target_pos if target_pos != Vector2.ZERO else worm.global_position
	var tile_pos = tile_map_layer.local_to_map(world_pos)
	
	match resource_type:
		"iron":
			# Original behavior: convert to coal
			var source_id = tile_map_layer.get_cell_source_id(tile_pos)
			if source_id == -1:
				print("No tile exists under worm. Skipping conversion.")
				return
			ConversionModule.convert_tile(tile_pos)
			
		"crystal":
			# Crystal becomes ice tile
			tile_map_layer.set_cell(tile_pos, 4, Vector2i(0, 0))  # 4 = Ice
			print("❄️ Converted crystal to ice at", tile_pos)
			
		"melon":
			# Melon location becomes water tile
			tile_map_layer.set_cell(tile_pos, 5, Vector2i(0, 0))  # 5 = Water
			print("💧 Converted melon area to water at", tile_pos)
