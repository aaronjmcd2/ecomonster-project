# PlayerPickupModule.gd
# Handles item pickup detection and logic for the player
# Uses: InventoryDataScript, InventoryUI

extends Node

var parent_node = null
var inventory_ui = null
var pickup_radius: float = 100.0

# Setup function called from the Player's _ready
func setup(player_node, inventory_ui_ref, radius: float = 100.0) -> void:
	parent_node = player_node
	inventory_ui = inventory_ui_ref
	pickup_radius = radius

# Try to pickup items near a world position
func try_pickup_item(world_pos: Vector2) -> bool:
	# Find all items within pickup radius
	var pickable_items = []
	
	# Get all potential pickable items from the scene
	var potential_items = []
	var scene_tree = parent_node.get_tree()
	
	# Get ore drops
	for item in scene_tree.get_nodes_in_group("ore_drops"):
		potential_items.append(item)
	
	# Get stone drops (specifically handle stones)
	for item in scene_tree.get_nodes_in_group("stone_drops"):
		potential_items.append(item)
		
	# Get melon items (specifically handle melons)
	for item in scene_tree.get_nodes_in_group("melons"):
		potential_items.append(item)
	
	# Get all other item groups
	var additional_groups = ["egg_drops", "world_items", "soul_drops", "crystal_shard_drops", 
							 "ingot_drops", "concrete_drops", "melon_drops", "glass_drops", "mana_drops"]
	for group in additional_groups:
		for item in scene_tree.get_nodes_in_group(group):
			if not potential_items.has(item): # Avoid duplicates
				potential_items.append(item)
	
	# Filter items by distance
	for item in potential_items:
		if is_instance_valid(item):
			var distance = item.global_position.distance_to(world_pos)
			if distance <= pickup_radius:
				pickable_items.append({"item": item, "distance": distance})
	
	# Sort by distance (closest first)
	pickable_items.sort_custom(Callable(self, "_sort_by_distance"))
	
	# Try to pick up the closest item
	if pickable_items.size() > 0:
		var item = pickable_items[0].item
		
		print("🖐️ Picking up: ", item.name, " (", item.get_groups(), ")")
		
		# Make sure the item has the get_item_data method
		if not item.has_method("get_item_data"):
			print("⚠️ Item doesn't have get_item_data method: ", item.name)
			if item.has_method("consume"):
				item.consume()
			else:
				item.queue_free()
			return true
		
		# Get item data
		var item_data = item.get_item_data()
		
		# Add to inventory
		inventory_ui.add_item_to_inventory(item_data)
		
		# Remove from world
		if item.has_method("consume"):
			item.consume()
		else:
			item.queue_free()
		
		return true
	
	return false

# Custom sort function for distance-based ordering
func _sort_by_distance(a, b):
	return a.distance < b.distance
