# SearchModule.gd
# Provides reusable functions to help monsters find ore drops and tiles by type.
# Used globally by Fire Elemental, Coal Worm, and others.
# Attached as Autoload singleton.

extends Node

var claimed_tile_positions := []

# === Finds the closest unclaimed ore drop within range and claims it ===
# origin: world position of the searching creature
# max_distance: maximum allowed search radius (in pixels)
# claimer: node who will "claim" the drop to prevent others from targeting it
# Returns: Node2D or null
func find_closest_ore_drop(origin: Vector2, max_distance: float, claimer: Node) -> Node2D:
	var closest_drop: Node2D = null
	var closest_dist := max_distance

	var all_drops := get_tree().get_nodes_in_group("ore_drops") + get_tree().get_nodes_in_group("egg_drops")
	for drop in all_drops:
		if drop.claimed_by != null:
			continue  # Already claimed by another

		var dist = origin.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	if closest_drop:
		closest_drop.claimed_by = claimer
		print("🔖 Drop claimed by:", claimer.name, "at", closest_drop.global_position)

	return closest_drop

# === Finds the nearest tile of a given source_id within a circular radius ===
# origin: world position of searcher
# radius: tile-based search radius (not in pixels)
# source_id: the tile type to look for (0 = coal, 2 = lava, etc.)
# Returns: Vector2 (world position of found tile) or null

# === Finds the closest unclaimed ore drop of a specific type ===
# origin: world position of the searching creature
# max_distance: maximum allowed search radius (in pixels)
# resource_type: string name of the type (e.g., "egg", "iron", "gold")
# claimer: the monster claiming it
# Returns: Node2D or null
func find_closest_drop_of_type(origin: Vector2, max_distance: float, resource_type: String, claimer: Node) -> Node2D:
	var closest_drop: Node2D = null
	var closest_dist := max_distance

	var all_drops := get_tree().get_nodes_in_group("ore_drops") + get_tree().get_nodes_in_group("egg_drops")
	for drop in all_drops:
		if drop.claimed_by != null and drop.claimed_by != claimer:
			continue

		if drop.resource_type != resource_type:
			continue

		var dist = origin.distance_to(drop.global_position)

		if dist > max_distance:
			continue

		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	if closest_drop:
		closest_drop.claimed_by = claimer
		print("🔖", resource_type.capitalize(), "drop claimed by:", claimer.name, "at", closest_drop.global_position)

	return closest_drop

func find_nearest_tile(origin: Vector2, radius: int, source_id: int) -> Variant:
	var tilemap = get_tree().current_scene.get_node("TileMap/TileMapLayer")
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
			var world_pos = tilemap.map_to_local(cell)

			# Skip if already claimed
			if cell_source == source_id and not world_pos in claimed_tile_positions:
				var dist = origin.distance_to(world_pos)
				if dist < closest_distance:
					closest_distance = dist
					closest_tile = world_pos
					found = true

	if found:
		claimed_tile_positions.append(closest_tile)

	return closest_tile if found else null
