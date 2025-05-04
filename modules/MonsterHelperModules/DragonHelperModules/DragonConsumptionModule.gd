# DragonConsumptionModule.gd
# Handles the consumption of tiles (lava, ice) and eggs for the Dragon

extends Node

func consume_tile(dragon: Node, target_tile, tile_map_layer: TileMapLayer) -> void:
	if get_total_storage(dragon) >= dragon.max_total_storage:
		return
		
	if not target_tile or (dragon.lava_storage >= dragon.max_lava_storage and dragon.ice_storage >= dragon.max_lava_storage):
		return

	var tile_pos = tile_map_layer.local_to_map(target_tile)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	match source_id:
		2:  # Lava
			tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Soil
			TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
			tile_map_layer.fix_invalid_tiles()
			dragon.lava_storage += 1
			SearchModule.claimed_tile_positions.erase(target_tile)

			if dragon.lava_storage >= dragon.required_lava_to_excrete and not dragon.is_cooling_down:
				dragon.is_cooling_down = true
				dragon.cooldown_timer = dragon.cooldown_time
				dragon.excretion_type = "lava"

		4:  # Ice
			tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # Soil
			TileRefreshModule.refresh_neighbors(tile_map_layer, tile_pos, true)
			tile_map_layer.fix_invalid_tiles()
			dragon.ice_storage += 1
			SearchModule.claimed_tile_positions.erase(target_tile)

			if dragon.ice_storage >= dragon.required_ice_to_excrete and not dragon.is_cooling_down:
				dragon.is_cooling_down = true
				dragon.cooldown_timer = dragon.cooldown_time
				dragon.excretion_type = "ice"

	dragon.target_tile = null

	print("ICE STORAGE:", dragon.ice_storage, " | REQUIRED:", dragon.required_ice_to_excrete, " | COOLING:", dragon.is_cooling_down)

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
