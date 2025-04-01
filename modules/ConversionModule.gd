extends Node

@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")

# Converts iron ore to coal or nearby soil
func convert_tile(tile_pos: Vector2i):
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	if source_id == -1:
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Initialize with soil
		await get_tree().process_frame

	if is_soil(tile_pos):
		tile_map_layer.set_cell(tile_pos, 0, Vector2i(0, 0))  # Replace with coal
		return

	var neighbor_tiles := get_neighbor_tiles(tile_pos)
	for neighbor in neighbor_tiles:
		if is_soil(neighbor):
			tile_map_layer.set_cell(neighbor, 0, Vector2i(0, 0))  # Replace with coal
			return

func get_neighbor_tiles(tile_pos: Vector2i) -> Array:
	return [
		tile_pos + Vector2i(1, 0), tile_pos + Vector2i(-1, 0),
		tile_pos + Vector2i(0, 1), tile_pos + Vector2i(0, -1)
	]

func is_soil(tile_pos: Vector2i) -> bool:
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	return source_id == 3  # Soil
