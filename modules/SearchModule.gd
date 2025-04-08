extends Node

# Finds the closest iron ore drop within a search radius
func find_closest_ore_drop(origin: Vector2, max_distance: float, claimer: Node) -> Node2D:
	var closest_drop: Node2D = null
	var closest_dist := max_distance

	for drop in get_tree().get_nodes_in_group("ore_drops"):
		if drop.claimed_by != null:
			continue  # Skip already claimed

		var dist = origin.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	if closest_drop:
		closest_drop.claimed_by = claimer
		print("🔖 Drop claimed by:", claimer.name, "at", closest_drop.global_position)

	return closest_drop


# Finds the nearest tile with the given source_id within the search radius
func find_nearest_tile(origin: Vector2, radius: int, source_id: int) -> Variant:
	var tilemap = get_tree().current_scene.get_node("TileMap/TileMapLayer") # This is the actual tilemap with the TileSet
	var layer_index = 0
	var closest_tile: Vector2 = Vector2.ZERO
	var closest_distance := INF
	var found := false
	var origin_cell = tilemap.local_to_map(origin)

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var offset = Vector2i(x, y)
			var cell = origin_cell + offset

			if offset.length() > radius:
				continue

			var cell_source = tilemap.get_cell_source_id(cell)
			if cell_source == source_id:
				var world_pos = tilemap.map_to_local(cell)
				var dist = origin.distance_to(world_pos)
				if dist < closest_distance:
					closest_distance = dist
					closest_tile = world_pos
					found = true

	return closest_tile if found else null
