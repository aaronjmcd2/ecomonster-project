# WormSearchModule.gd
# Dedicated search module for Coal Worm behavior
# Finds unclaimed iron ore drops within a search radius

extends Node

func find_closest_iron_drop(origin: Vector2, max_distance: float, claimer: Node) -> Node2D:
	var closest_drop: Node2D = null
	var closest_dist := max_distance

	for drop in get_tree().get_nodes_in_group("ore_drops"):
		if not is_instance_valid(drop):
			continue

		if drop.resource_type != "iron":
			continue

		if drop.claimed_by != null and drop.claimed_by != claimer:
			continue

		var dist = origin.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop


	if closest_drop:
		closest_drop.claimed_by = claimer
		print("🔩 Iron drop claimed by:", claimer.name, "at", closest_drop.global_position)

	return closest_drop
