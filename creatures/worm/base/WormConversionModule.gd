# CoalWormConversionModule.gd
# Enhanced to handle different conversion types

extends Node

# Convert tile or create drops based on consumed resource type
func convert_tile_beneath(worm: Node, tile_map_layer: TileMapLayer, resource_type: String = "iron", target_pos: Vector2 = Vector2.ZERO) -> void:
	# Use target position if provided, otherwise use worm position
	var world_pos = target_pos if target_pos != Vector2.ZERO else worm.global_position
	var tile_pos = tile_map_layer.local_to_map(world_pos)
	
	match resource_type:
		"iron":
			# Original behavior: convert to coal
			var source_id = tile_map_layer.get_cell_source_id(tile_pos)
			if source_id == -1:
				print("No tile exists under worm. Skipping conversion.")
				return
			ConversionModule.convert_tile(tile_pos)
			
		"boulder":
			# Boulder creates stone drops
			_create_stone_drops(worm, world_pos)
			print("⛰️ Boulder broken into stones at", world_pos)

# Create stone drops when boulder is consumed
func _create_stone_drops(worm: Node, position: Vector2) -> void:
	var stone_scene = preload("res://items/drops/resources/Stone.tscn")
	var num_stones = randi_range(2, 4)  # Create 2-4 stone drops
	
	# Get the tree from the worm
	var tree = worm.get_tree()
	if not tree:
		print("Error: Could not get scene tree")
		return
		
	var current_scene = tree.current_scene
	
	for i in num_stones:
		var stone = stone_scene.instantiate()
		# Randomize position slightly around the boulder
		var offset = Vector2(
			randi_range(-32, 32),
			randi_range(-32, 32)
		)
		stone.global_position = position + offset
		current_scene.add_child(stone)
