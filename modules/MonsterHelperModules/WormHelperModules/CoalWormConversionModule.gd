# CoalWormConversionModule.gd
# Handles tile conversion beneath the worm

extends Node

# Convert tile beneath worm to coal
func convert_tile_beneath(worm: Node, tile_map_layer: TileMapLayer) -> void:
	var tile_pos = tile_map_layer.local_to_map(worm.global_position)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		print("No tile exists under worm. Skipping conversion.")
		return
	
	ConversionModule.convert_tile(tile_pos)
