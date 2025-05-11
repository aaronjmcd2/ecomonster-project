# ConversionModule.gd
# Handles tile conversion logic: turning iron ore into coal, lava into soil, and generic tile replacements.
# Attached as Autoload singleton.

extends Node

@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")

# === Converts an iron ore drop's tile or nearby soil to coal ===
# tile_pos: Vector2i — map position under or near the drop
func convert_tile(tile_pos: Vector2i) -> void:
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	# If tile doesn't exist, initialize it with soil
	if source_id == -1:
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # 3 = Soil
		# This yield was likely used to wait for set_cell to complete — usually unnecessary
		# await get_tree().process_frame

	# If the tile is now soil, replace with coal
	if is_soil(tile_pos):
		tile_map_layer.set_cell(tile_pos, 0, Vector2i(0, 0))  # 0 = Coal
		return

	# Otherwise try nearby tiles
	var neighbor_tiles := get_neighbor_tiles(tile_pos)
	for neighbor in neighbor_tiles:
		if is_soil(neighbor):
			tile_map_layer.set_cell(neighbor, 0, Vector2i(0, 0))  # 0 = Coal
			return

# === Returns 4-directional neighbor tile positions ===
func get_neighbor_tiles(tile_pos: Vector2i) -> Array:
	return [
		tile_pos + Vector2i(1, 0),
		tile_pos + Vector2i(-1, 0),
		tile_pos + Vector2i(0, 1),
		tile_pos + Vector2i(0, -1)
	]

# === Checks if the given tile is soil ===
func is_soil(tile_pos: Vector2i) -> bool:
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	return source_id == 3  # 3 = Soil

# === Replaces a tile at world position if it matches a source ID ===
# world_position: Vector2 — world-space coordinates (not tile-space)
# from_source_id: int — current tile type expected
# to_source_id: int — new tile type to place
func replace_tile(world_position: Vector2, from_source_id: int, to_source_id: int) -> void:
	var tile_pos = tile_map_layer.local_to_map(world_position)
	var current_source = tile_map_layer.get_cell_source_id(tile_pos)

	if current_source == from_source_id:
		tile_map_layer.set_cell(tile_pos, to_source_id, Vector2i(0, 0))
