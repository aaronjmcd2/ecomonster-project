extends Node

# Finds the closest iron ore drop within a search radius
func find_closest_ore_drop(origin: Vector2, max_distance: float) -> Node2D:
	var closest_drop: Node2D = null
	var closest_dist := max_distance

	for drop in get_tree().get_nodes_in_group("ore_drops"):
		var dist = origin.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	return closest_drop
