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

		# Check distance to avoid picking up items too far away
		if player.global_position.distance_to(node.global_position) > pickup_radius:
			continue

		# Prioritize the get_item_data method if it exists
		if node.has_method("get_item_data"):
			print("✨ Picking up item using get_item_data(): ", node.name)
			var item_data = node.get_item_data()
			print("📦 Item data: ", item_data)
			inventory_ui.add_item_to_inventory(item_data.duplicate(true))
			node.queue_free()
			return
		
		# For nodes without get_item_data, handle based on groups
		if node.is_in_group("aetherdrift_ore_drops"):
			_pickup_specific_ore(node, "AetherdriftOre", "aetherdrift ore")
			return
		elif node.is_in_group("silver_ore_drops"):
			_pickup_specific_ore(node, "SilverOre", "silver ore")
			return
		elif node.is_in_group("gold_ore_drops"):
			_pickup_specific_ore(node, "GoldOre", "gold ore")  
			return
		elif node.is_in_group("ore_drops"):
			# Generic ore_drops are assumed to be iron if not in a more specific group
			_pickup_specific_ore(node, "IronOre", "iron ore")
			return
		elif node.is_in_group("ingot_drops"):
			# Try to determine ingot type from resource_type if available
			var ingot_type = "IronIngot"  # Default
			if "resource_type" in node:
				match node.resource_type:
					"iron_ingot": ingot_type = "IronIngot"
					"silver_ingot": ingot_type = "SilverIngot"
					"gold_ingot": ingot_type = "GoldIngot"
					"aetherdrift_ingot": ingot_type = "AetherdriftIngot"
			
			_pickup_specific_ore(node, ingot_type, "ingot")
			return
		elif node.is_in_group("concrete_drops"):
			_pickup_specific_ore(node, "ReinforcedConcrete", "reinforced concrete")
			return
		
		# Add other item types as needed

# Helper function to handle picking up specific ore types
func _pickup_specific_ore(node, item_name: String, display_name: String) -> void:
	print("🔹 Picking up " + display_name + ": " + node.name)
	var drop_count = node.get("count") if "count" in node else 1
	var item_data = {
		"name": item_name,
		"count": drop_count
	}
	print("📦 Item data: ", item_data)
	inventory_ui.add_item_to_inventory(item_data.duplicate(true))
	node.queue_free()
