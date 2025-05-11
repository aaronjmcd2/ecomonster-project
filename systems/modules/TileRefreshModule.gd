# TileRefreshModule.gd
# Helper for manually refreshing neighbor tiles in TileMapLayer

extends Node

static func refresh_neighbors(tilemap: TileMapLayer, pos: Vector2i, include_center: bool = false) -> void:
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                 Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]

	if include_center:
		directions.append(Vector2i(0, 0))

	for dir in directions:
		var neighbor_pos = pos + dir
		var source_id = tilemap.get_cell_source_id(neighbor_pos)
		var atlas_coords = tilemap.get_cell_atlas_coords(neighbor_pos)

		if source_id != -1:
			# Re-apply the same tile to encourage Godot to refresh
			tilemap.set_cell(neighbor_pos, source_id, atlas_coords)
