# DragonConsumptionModule.gd
# Handles the consumption of tiles (lava, ice) and eggs for the Dragon

extends Node

func consume_tile(dragon: Node, target_tile, tile_map_layer: TileMapLayer) -> void:
	if get_total_storage(dragon) >= dragon.max_total_storage:
		return
		
	if not target_tile or (dragon.lava_storage >= dragon.max_lava_storage and dragon.ice_storage >= dragon.max_lava_storage):
		return

	var tile_pos = tile_map_layer.local_to_map(target_tile)
	
	# Use the tile module to convert the tile and get the original type
	var original_source = dragon.tile_module.convert_to_soil(dragon, tile_pos, tile_map_layer)
	
	if original_source != -1:
		# Process the resource based on its type
		dragon.tile_module.process_resource(dragon, original_source)
		
		# Release the tile from the claimed positions
		dragon.tile_module.release_tile(target_tile)
		
		# Clear the target tile
		dragon.target_tile = null

func consume_egg(dragon: Node, target_egg: Node) -> void:
	if get_total_storage(dragon) >= dragon.max_total_storage:
		return

	if not target_egg or dragon.egg_storage >= dragon.max_lava_storage:
		return

	if target_egg.is_inside_tree():
		target_egg.queue_free()

	dragon.egg_storage += 1
	dragon.target_egg = null

	if dragon.egg_storage >= dragon.required_eggs_to_excrete and not dragon.is_cooling_down:
		dragon.is_cooling_down = true
		dragon.cooldown_timer = dragon.cooldown_time
		dragon.excretion_type = "egg"

func get_total_storage(dragon: Node) -> int:
	return dragon.lava_storage + dragon.ice_storage + dragon.egg_storage
