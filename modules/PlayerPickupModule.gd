# PlayerPickupModule.gd
# Handles item pickup (ore and world items) for the player.

extends Node

var player: Node2D = null
var inventory_ui: Node = null
var pickup_radius: float = 800.0

func setup(p, ui, radius):
	player = p
	inventory_ui = ui
	pickup_radius = radius

func try_pickup_item(world_pos: Vector2) -> void:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = player.get_world_2d().direct_space_state.intersect_point(query)

	for result in results:
		var node = result.get("collider")
		if node == null:
			continue

		if node.is_in_group("ore_drops"):
			if player.global_position.distance_to(node.global_position) <= pickup_radius:
				print("✨ Picked up:", node.name)
				var drop_count = node.count
				var item_data = {
					"name": "IronOre",
					"count": drop_count
				}
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))
				node.queue_free()
				break
				
		elif node.is_in_group("egg_drops"):
			if player.global_position.distance_to(node.global_position) <= pickup_radius:
				print("🥚 Picked up egg:", node.name)
				var drop_count = node.count
				var item_data = {
					"name": "Egg",  # ✅ Corrected from "IronOre"
					"count": drop_count
				}
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))
				node.queue_free()
				break
				
		elif node.is_in_group("gold_ore_drops"):
			if player.global_position.distance_to(node.global_position) <= pickup_radius:
				print("🪙 Picked up gold:", node.name)
				var drop_count = node.count
				var item_data = {
					"name": "GoldOre",
					"count": drop_count
				}
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))
				node.queue_free()
				break

		elif node.is_in_group("silver_ore_drops"):
			if player.global_position.distance_to(node.global_position) <= pickup_radius:
				print("🥈 Picked up silver:", node.name)
				var drop_count = node.count
				var item_data = {
					"name": "SilverOre",
					"count": drop_count
				}
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))
				node.queue_free()
				break



		elif node.is_in_group("world_items"):
			if player.global_position.distance_to(node.global_position) <= pickup_radius:
				print("🗡️ Picked up world item:", node.name)
				var item_data = node.get_item_data()
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))
				node.queue_free()
				break
