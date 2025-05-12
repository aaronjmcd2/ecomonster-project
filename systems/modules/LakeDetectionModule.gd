# LakeDetectionModule.gd
# Handles detecting lakes (3x3+ connected water tiles) and foggy state
extends Node

# Lake data structure
# A "lake" is a collection of connected water tiles
# Format: Dictionary with:
#   - "tiles": Array of Vector2i positions
#   - "is_foggy": Boolean
#   - "fog_timer": Float (remaining time for fog effect)
var lakes = []

# Detects lakes in the tilemap
# Returns: Array of lakes (each a dictionary with lake data)
# Detects lakes in the tilemap
# Returns: Array of lakes (each a dictionary with lake data)
func detect_lakes(tile_map_layer: TileMapLayer) -> Array:
	var water_tiles = []
	var lake_size_threshold = 9  # 3x3 minimum
	
	# Step 1: Find all water tiles
	# Water tiles have source_id = 5 (based on existing system)
	for x in range(-100, 100):  # Adjust range as needed
		for y in range(-100, 100):
			var pos = Vector2i(x, y)
			if tile_map_layer.get_cell_source_id(pos) == 5:  # Water tile
				water_tiles.append(pos)
	
	print("Found " + str(water_tiles.size()) + " water tiles total")
	
	# Step 2: Group connected water tiles into lakes
	var visited = {}
	var new_lakes = []
	
	for tile_pos in water_tiles:
		if visited.has(tile_pos):
			continue
			
		# Flood fill to find all connected tiles
		var lake_tiles = []
		var queue = [tile_pos]
		
		while not queue.is_empty():
			var current = queue.pop_front()
			if visited.has(current):
				continue
				
			visited[current] = true
			lake_tiles.append(current)
			
			# Check four adjacent tiles
			var neighbors = [
				Vector2i(current.x + 1, current.y),
				Vector2i(current.x - 1, current.y),
				Vector2i(current.x, current.y + 1),
				Vector2i(current.x, current.y - 1)
			]
			
			for neighbor in neighbors:
				if neighbor in water_tiles and not visited.has(neighbor):
					queue.push_back(neighbor)
		
		# Create lake if it meets size threshold
		if lake_tiles.size() >= lake_size_threshold:
			print("Found lake with " + str(lake_tiles.size()) + " tiles")
			
			var existing_lake = _find_existing_lake(lake_tiles)
			if !existing_lake.is_empty():
				# Update existing lake
				existing_lake.tiles = lake_tiles
			else:
				# Create new lake
				new_lakes.append({
					"tiles": lake_tiles,
					"is_foggy": false,
					"fog_timer": 0.0,
					"spawn_timer": 0.0
				})
	
	# Keep track of detected lakes
	self.lakes = new_lakes
	return new_lakes
	
# Finds if any tiles in a lake match an existing lake
func _find_existing_lake(tiles: Array) -> Dictionary:
	for lake in lakes:
		for tile in lake.tiles:
			if tile in tiles:
				return lake
	return {}  # Return empty Dictionary instead of null

# Makes a lake foggy when silver ingot is dropped into it
func make_lake_foggy(tile_map_layer: TileMapLayer, pos: Vector2) -> bool:
	var map_pos = tile_map_layer.local_to_map(pos)
	
	# Check if position is in a lake
	for lake in lakes:
		if map_pos in lake.tiles:
			lake.is_foggy = true
			lake.fog_timer = 300.0  # 5 minutes
			return true
	
	return false

# Updates fog timers and removes fog when timer expires
func update_lakes(delta: float) -> void:
	for lake in lakes:
		if lake.is_foggy:
			lake.fog_timer -= delta
			
			# Reset fog if timer expires
			if lake.fog_timer <= 0:
				lake.is_foggy = false
				lake.fog_timer = 0.0
				
			# Update spawn timer for specters
			if lake.has("spawn_timer") and lake.spawn_timer > 0:
				lake.spawn_timer -= delta
