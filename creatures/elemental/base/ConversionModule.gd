# FireElementalConversionModule.gd
# Handles resource conversion

extends Node

# Convert the current target resource
func convert_resource(elemental: Node, target_data: Dictionary) -> void:
	match target_data.resource_type:
		"coal_drop":
			elemental.lava_stat.add(1)
			# New behavior - coal drop to lava tile
			_convert_coal_drop_to_lava(elemental, target_data.target)
			
		"coal":
			elemental.lava_stat.add(1)
			# Original behavior - coal to lava
			ConversionModule.replace_tile(target_data.target, 0, 2)  # 0 = Coal, 2 = Lava
			SearchModule.claimed_tile_positions.erase(target_data.target)
			
		"crystal":
			# Crystal to ice
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 4, Vector2i(0, 0))  # 4 = Ice
			if target_data.target.has_method("consume"):
				target_data.target.consume()
			print("❄️ Fire Elemental converted crystal to ice at", tile_pos)
			
		"melon":
			# Melon to water
			var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
			var tile_pos = tilemap.local_to_map(target_data.target.global_position)
			tilemap.set_cell(tile_pos, 5, Vector2i(0, 0))  # 5 = Water
			if target_data.target.has_method("harvest"):
				target_data.target.harvest(true)  # true = consumed by monster
			print("💧 Fire Elemental converted melon to water at", tile_pos)

# Convert coal drop(s) to lava tile - handles multiple drops on same tile
func _convert_coal_drop_to_lava(elemental: Node, primary_coal_drop: Node) -> void:
	var tilemap = elemental.get_tree().current_scene.get_node("TileMap/TileMapLayer")
	if not tilemap:
		print("❌ TileMap not found for coal drop conversion")
		return
	
	# Get the tile position of the primary coal drop - account for TileMap transform
	var tilemap_node = elemental.get_tree().current_scene.get_node("TileMap")
	var local_position = tilemap_node.to_local(primary_coal_drop.global_position)
	var tile_pos = tilemap.local_to_map(local_position)
	
	# Find all coal drops on the same tile and consume them
	var consumed_count = 0
	var tree = elemental.get_tree()
	
	for coal_drop in tree.get_nodes_in_group("ore_drops"):
		# Check if it's a coal drop
		if coal_drop.has_method("get_item_data"):
			var item_data = coal_drop.get_item_data()
			if item_data.name != "Coal":
				continue
		else:
			continue
			
		# Check if it's on the same tile - use same coordinate transformation
		var drop_local_position = tilemap_node.to_local(coal_drop.global_position)
		var drop_tile_pos = tilemap.local_to_map(drop_local_position)
		if drop_tile_pos == tile_pos:
			# Consume this coal drop
			if coal_drop.has_method("consume"):
				coal_drop.consume()
			else:
				coal_drop.queue_free()
			consumed_count += 1
	
	# Convert the tile to lava
	tilemap.set_cell(tile_pos, 2, Vector2i(0, 0))  # 2 = Lava
	
	print("🔥 Fire Elemental converted %d coal drop(s) to lava at %s" % [consumed_count, tile_pos])
