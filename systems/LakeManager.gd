# Update fog effects for each lake
func _update_fog_effects():
	# Add fog to newly foggy lakes
	for i in range(lakes.size()):
		var lake = lakes[i]
		
		# Add fog effect if the lake is foggy and doesn't have one
		if lake.is_foggy and not fog_effects.has(i):
			var fog = fog_effect_scene.instantiate()
			
			# Calculate center of lake
			var center = Vector2.ZERO
			for tile_pos in lake.tiles:
				center += Vector2(tile_pos.x, tile_pos.y)
			center /= lake.tiles.size()
			
			# Convert to world position
			center = Vector2(center.x * 32, center.y * 32)
			
			# Calculate size based on lake size
			var size = sqrt(lake.tiles.size()) * 32 * 2  # Rough estimate
			
			# Position the fog effect at the lake center
			fog.position = center
			
			# Set the bounds for the fog effect
			fog.set_bounds(Vector2(size, size))
			
			add_child(fog)
			fog_effects[i] = fog
			
			print("🌫️ Created fog effect for lake at ", center)
		
		# Remove fog effect if the lake is no longer foggy
		elif not lake.is_foggy and fog_effects.has(i):
			fog_effects[i].queue_free()
			fog_effects.erase(i)
